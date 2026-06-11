import logging
from datetime import datetime, timezone, timedelta
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.repositories.user_repository import UserRepository
from app.core.security import get_password_hash, verify_password, create_token_pair, verify_token
from app.models.user import User, UserSession
from app.schemas.auth import SignUpRequest, SignInRequest, TokenResponse, GoogleSignInRequest

logger = logging.getLogger(__name__)

REFRESH_GRACE_PERIOD_SECONDS = 10

class AuthService:
    def __init__(self, db: Session):
        self.repo = UserRepository(db)

    def register(self, data: SignUpRequest) -> User:
        logger.info(f"Registering user: {data.email}, role: {data.role}")

        if self.repo.get_user_by_identity(data.email):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this email already exists"
            )
        if data.phone and self.repo.get_user_by_identity(data.phone):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this phone number already exists"
            )

        try:
            new_user = User(
                email=data.email,
                phone=data.phone,
                full_name=data.full_name,
                hashed_password=get_password_hash(data.password),
                role=str(data.role),
                is_verified=False,
                created_at=datetime.now(timezone.utc)
            )
            user = self.repo.create_user(new_user)

            # Generate verification code
            import random
            from app.models.user import VerificationCode
            from app.services.email_service import send_verification_email
            code = f"{random.randint(100000, 999999)}"
            expires_at = datetime.now(timezone.utc) + timedelta(minutes=10)

            verification_entry = VerificationCode(
                email=user.email,
                code=code,
                expires_at=expires_at
            )
            self.repo.db.add(verification_entry)
            self.repo.db.commit()

            send_verification_email(user.email, code)
            return user
        except Exception as e:
            logger.error(f"Error creating user in DB: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Database error: {str(e)}"
            )

    def login(self, data: SignInRequest, meta: dict) -> TokenResponse:
        user = self.repo.get_user_by_identity(data.email_or_phone)
        if not user or not verify_password(data.password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is deactivated"
            )

        if not user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="EMAIL_NOT_VERIFIED"
            )

        self.repo.revoke_all_user_sessions(user.id)
        tokens = create_token_pair(user.id)

        session = UserSession(
            user_id=user.id,
            refresh_token_hash=get_password_hash(tokens["refresh_token"]),
            refresh_jti=tokens["jti"],
            device_fingerprint=meta["fingerprint"],
            device_name=meta["device_name"],
            ip_address=meta["ip"],
            expires_at=tokens["refresh_expires_at"]
        )
        self.repo.create_session(session)

        return TokenResponse(
            access_token=tokens["access_token"],
            refresh_token=tokens["refresh_token"],
            expires_in=tokens["expires_in"]
        )

    def refresh_tokens(self, refresh_token: str, meta: dict) -> TokenResponse:
        payload = verify_token(refresh_token, expected_type="refresh")
        user_id = int(payload["sub"])
        jti = payload.get("jti")

        if not jti:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid refresh token"
            )

        user = self.repo.get_user_by_id(user_id)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or deactivated"
            )

        self.repo.clear_expired_grace_tokens(user_id)

        active_session = self.repo.find_active_session_by_refresh_token(user_id, refresh_token)
        if active_session:
            return self._rotate_session(active_session, user_id, meta)

        grace_session = self.repo.find_grace_session_by_refresh_token(user_id, refresh_token, jti)
        if grace_session:
            logger.info(f"Grace-period refresh accepted for user {user_id}, jti={jti}")
            return TokenResponse(
                access_token=grace_session.grace_access_token,
                refresh_token=grace_session.grace_refresh_token,
                expires_in=900
            )

        revoked_session = self.repo.find_revoked_session_by_refresh_token(user_id, refresh_token)
        if revoked_session:
            logger.warning(f"Refresh token reuse detected for user {user_id}, jti={jti}")
            self.repo.revoke_all_user_sessions(user_id)
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token reuse detected. Please sign in again."
            )

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )

    def _rotate_session(self, old_session: UserSession, user_id: int, meta: dict) -> TokenResponse:
        tokens = create_token_pair(user_id)

        self.repo.apply_rotation_grace(
            old_session,
            access_token=tokens["access_token"],
            refresh_token=tokens["refresh_token"],
            grace_seconds=REFRESH_GRACE_PERIOD_SECONDS,
        )

        new_session = UserSession(
            user_id=user_id,
            refresh_token_hash=get_password_hash(tokens["refresh_token"]),
            refresh_jti=tokens["jti"],
            device_fingerprint=meta.get("fingerprint", "unknown"),
            device_name=meta.get("device_name", "unknown"),
            ip_address=meta.get("ip", "0.0.0.0"),
            expires_at=tokens["refresh_expires_at"]
        )
        self.repo.create_session(new_session)

        return TokenResponse(
            access_token=tokens["access_token"],
            refresh_token=tokens["refresh_token"],
            expires_in=tokens["expires_in"]
        )

    def google_signin(self, data: GoogleSignInRequest, meta: dict) -> TokenResponse:
        email = data.email
        if not data.id_token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Google ID token is required"
            )

        try:
            from google.oauth2 import id_token
            from google.auth.transport import requests as google_requests
            
            # Verify the token signature.
            id_info = id_token.verify_oauth2_token(
                data.id_token, google_requests.Request(), audience=None
            )
            
            token_email = id_info.get("email")
            if not token_email or token_email.lower() != email.lower():
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Email in token does not match requested email"
                )
        except Exception as e:
            logger.error(f"Google ID token verification failed: {e}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Google ID token verification failed: {str(e)}"
            )

        user = self.repo.get_user_by_identity(email)
        
        if not user:
            role = data.role or "farmer_business"
            
            if data.phone and self.repo.get_user_by_identity(data.phone):
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="User with this phone number already exists"
                )
            
            import secrets
            random_pwd = secrets.token_urlsafe(16)
            user = User(
                email=data.email,
                phone=data.phone,
                full_name=data.full_name,
                hashed_password=get_password_hash(random_pwd),
                role=str(role),
                is_verified=True,
                created_at=datetime.now(timezone.utc)
            )
            user = self.repo.create_user(user)
        
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is deactivated"
            )
            
        self.repo.revoke_all_user_sessions(user.id)
        tokens = create_token_pair(user.id)
        
        session = UserSession(
            user_id=user.id,
            refresh_token_hash=get_password_hash(tokens["refresh_token"]),
            refresh_jti=tokens["jti"],
            device_fingerprint=meta["fingerprint"],
            device_name=meta["device_name"],
            ip_address=meta["ip"],
            expires_at=tokens["refresh_expires_at"]
        )
        self.repo.create_session(session)
        
        return TokenResponse(
            access_token=tokens["access_token"],
            refresh_token=tokens["refresh_token"],
            expires_in=tokens["expires_in"]
        )

    def verify_email(self, email: str, code: str) -> User:
        from app.models.user import VerificationCode
        now = datetime.now(timezone.utc)
        
        # Get latest verification code for email
        entry = self.repo.db.query(VerificationCode).filter(
            VerificationCode.email == email
        ).order_by(VerificationCode.created_at.desc()).first()
        
        if not entry:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Код подтверждения не найден"
            )
            
        if entry.attempts >= 5:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Превышено количество попыток. Запросите новый код."
            )

        if entry.code != code:
            entry.attempts += 1
            self.repo.db.commit()
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Неверный код подтверждения. Осталось попыток: {5 - entry.attempts}"
            )
            
        if entry.expires_at < now:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Срок действия кода истек"
            )
            
        user = self.repo.get_user_by_identity(email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Пользователь не найден"
            )
            
        user.is_verified = True
        # Clear verification codes
        self.repo.db.query(VerificationCode).filter(VerificationCode.email == email).delete()
        self.repo.db.commit()
        self.repo.db.refresh(user)
        return user

    def resend_verification_code(self, email: str):
        user = self.repo.get_user_by_identity(email)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Пользователь не найден"
            )
        if user.is_verified:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email уже подтвержден"
            )
        import random
        from app.models.user import VerificationCode
        from app.services.email_service import send_verification_email
        
        # Invalidate past codes
        self.repo.db.query(VerificationCode).filter(VerificationCode.email == email).delete()
        
        code = f"{random.randint(100000, 999999)}"
        expires_at = datetime.now(timezone.utc) + timedelta(minutes=10)
        
        verification_entry = VerificationCode(
            email=email,
            code=code,
            expires_at=expires_at
        )
        self.repo.db.add(verification_entry)
        self.repo.db.commit()
        
        send_verification_email(email, code)

