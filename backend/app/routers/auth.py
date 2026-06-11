from datetime import datetime, timezone, timedelta
from fastapi import APIRouter, Depends, Header, Request, status, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.auth import BaseResponse, SignUpRequest, SignInRequest, TokenResponse, UserDetailResponse, PinSetupRequest, UpdateSettingsRequest, GoogleSignInRequest
from app.services.auth_service import AuthService
from app.core.security import get_password_hash
from app.repositories.user_repository import UserRepository

router = APIRouter()

@router.post("/signup", response_model=BaseResponse[UserDetailResponse], status_code=status.HTTP_201_CREATED)
def signup(data: SignUpRequest, db: Session = Depends(get_db)):
    """Handles new user registration."""
    service = AuthService(db)
    user = service.register(data)
    return BaseResponse(data=UserDetailResponse.model_validate(user))

@router.post("/signin", response_model=BaseResponse[TokenResponse])
def signin(
    data: SignInRequest,
    request: Request,
    x_device_fingerprint: str = Header(...),
    x_device_name: str = Header(...),
    db: Session = Depends(get_db)
):
    """Authenticates user and returns access/refresh token pair."""
    service = AuthService(db)
    meta = {
        "fingerprint": x_device_fingerprint,
        "device_name": x_device_name,
        "ip": request.client.host if request.client else "0.0.0.0"
    }
    tokens = service.login(data, meta)
    return BaseResponse(data=tokens)

@router.post("/refresh", response_model=BaseResponse[TokenResponse])
def refresh(
    refresh_token: str,
    request: Request,
    x_device_fingerprint: str = Header("unknown"),
    x_device_name: str = Header("unknown"),
    db: Session = Depends(get_db)
):
    """Refreshes the access token using a valid refresh token."""
    service = AuthService(db)
    meta = {
        "fingerprint": x_device_fingerprint,
        "device_name": x_device_name,
        "ip": request.client.host if request.client else "0.0.0.0"
    }
    tokens = service.refresh_tokens(refresh_token, meta)
    return BaseResponse(data=tokens)

@router.post("/pin-setup", response_model=BaseResponse[str])
def pin_setup(
    data: PinSetupRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Sets a 4-digit PIN code for quick biometric/PIN entry."""
    repo = UserRepository(db)
    repo.update_user_pin(current_user.id, get_password_hash(data.pin_code))
    return BaseResponse(data="PIN successfully set")

@router.patch("/update-settings", response_model=BaseResponse[UserDetailResponse])
def update_settings(
    data: UpdateSettingsRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Updates user profile settings like biometric preference or name."""
    repo = UserRepository(db)
    user = repo.get_user_by_id(current_user.id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if data.is_biometric_enabled is not None:
        user.is_biometric_enabled = data.is_biometric_enabled
    if data.full_name is not None:
        user.full_name = data.full_name

    db.commit()
    db.refresh(user)
    return BaseResponse(data=UserDetailResponse.model_validate(user))

@router.post("/activate-premium", response_model=BaseResponse[str])
def activate_premium(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Simulation of premium purchase for 30 days."""
    current_user.is_premium = True
    current_user.premium_until = datetime.now(timezone.utc) + timedelta(days=30)
    db.commit()
    return BaseResponse(data="PREMIUM_ACTIVATED_FOR_30_DAYS")

@router.delete("/delete-account", response_model=BaseResponse[str])
def delete_account(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Permanently deletes the user account and all associated data."""
    repo = UserRepository(db)
    user = repo.get_user_by_id(current_user.id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    db.delete(user)
    db.commit()
    return BaseResponse(data="Account successfully deleted")

@router.get("/me", response_model=BaseResponse[UserDetailResponse])
def get_me(current_user: User = Depends(get_current_user)):
    """Returns details of the currently authenticated user."""
    return BaseResponse(data=UserDetailResponse.model_validate(current_user))

@router.post("/google-signin", response_model=BaseResponse[TokenResponse])
def google_signin(
    data: GoogleSignInRequest,
    request: Request,
    x_device_fingerprint: str = Header("unknown"),
    x_device_name: str = Header("unknown"),
    db: Session = Depends(get_db)
):
    """Authenticates user via Google. Registers new user if phone & role are provided."""
    service = AuthService(db)
    meta = {
        "fingerprint": x_device_fingerprint,
        "device_name": x_device_name,
        "ip": request.client.host if request.client else "0.0.0.0"
    }
    tokens = service.google_signin(data, meta)
    return BaseResponse(data=tokens)

