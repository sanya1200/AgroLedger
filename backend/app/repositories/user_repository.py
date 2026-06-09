from datetime import datetime, timezone
from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import or_
from app.models.user import User, UserSession
from app.core.security import verify_password

class UserRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_user_by_identity(self, identity: str) -> Optional[User]:
        return self.db.query(User).filter(
            or_(User.email == identity, User.phone == identity)
        ).first()

    def get_user_by_id(self, user_id: int) -> Optional[User]:
        return self.db.query(User).filter(User.id == user_id).first()

    def create_user(self, user: User) -> User:
        try:
            self.db.add(user)
            self.db.commit()
            self.db.refresh(user)
            return user
        except Exception:
            self.db.rollback()
            raise

    def update_user_pin(self, user_id: int, hashed_pin: str):
        user = self.get_user_by_id(user_id)
        if user:
            user.hashed_pin = hashed_pin
            self.db.commit()

    def create_session(self, session: UserSession) -> UserSession:
        self.db.add(session)
        self.db.commit()
        self.db.refresh(session)
        return session

    def get_session_by_hash(self, token_hash: str) -> Optional[UserSession]:
        return self.db.query(UserSession).filter(
            UserSession.refresh_token_hash == token_hash,
            UserSession.is_revoked == False
        ).first()

    def revoke_session(self, session: UserSession):
        session.is_revoked = True
        session.revoked_at = datetime.now(timezone.utc)
        self.db.commit()

    def revoke_all_user_sessions(self, user_id: int):
        now = datetime.now(timezone.utc)
        self.db.query(UserSession).filter(
            UserSession.user_id == user_id,
            UserSession.is_revoked == False
        ).update({"is_revoked": True, "revoked_at": now})
        self.db.commit()

    def get_active_sessions_for_user(self, user_id: int) -> List[UserSession]:
        now = datetime.now(timezone.utc)
        return self.db.query(UserSession).filter(
            UserSession.user_id == user_id,
            UserSession.is_revoked == False,
            UserSession.expires_at > now,
        ).all()

    def find_active_session_by_refresh_token(
        self, user_id: int, refresh_token: str
    ) -> Optional[UserSession]:
        for session in self.get_active_sessions_for_user(user_id):
            if verify_password(refresh_token, session.refresh_token_hash):
                return session
        return None

    def find_grace_session_by_refresh_token(
        self, user_id: int, refresh_token: str, jti: str
    ) -> Optional[UserSession]:
        now = datetime.now(timezone.utc)
        candidates = self.db.query(UserSession).filter(
            UserSession.user_id == user_id,
            UserSession.is_revoked == True,
            UserSession.refresh_jti == jti,
            UserSession.grace_expires_at.isnot(None),
            UserSession.grace_expires_at > now,
        ).all()

        for session in candidates:
            if verify_password(refresh_token, session.refresh_token_hash):
                return session
        return None

    def find_revoked_session_by_refresh_token(
        self, user_id: int, refresh_token: str
    ) -> Optional[UserSession]:
        sessions = self.db.query(UserSession).filter(
            UserSession.user_id == user_id,
            UserSession.is_revoked == True,
        ).all()

        for session in sessions:
            if verify_password(refresh_token, session.refresh_token_hash):
                return session
        return None

    def apply_rotation_grace(
        self,
        session: UserSession,
        access_token: str,
        refresh_token: str,
        grace_seconds: int,
    ):
        from datetime import timedelta
        now = datetime.now(timezone.utc)
        session.is_revoked = True
        session.revoked_at = now
        session.grace_access_token = access_token
        session.grace_refresh_token = refresh_token
        session.grace_expires_at = now + timedelta(seconds=grace_seconds)
        self.db.commit()

    def clear_expired_grace_tokens(self, user_id: int):
        now = datetime.now(timezone.utc)
        self.db.query(UserSession).filter(
            UserSession.user_id == user_id,
            UserSession.grace_expires_at.isnot(None),
            UserSession.grace_expires_at <= now,
        ).update({
            "grace_access_token": None,
            "grace_refresh_token": None,
            "grace_expires_at": None,
        })
        self.db.commit()
