from fastapi import APIRouter, Depends, Header, Request, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.schemas.auth import BaseResponse, SignUpRequest, SignInRequest, TokenResponse, UserDetailResponse, PinSetupRequest
from app.services.auth_service import AuthService
from app.core.security import verify_token, get_password_hash
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
    authorization: str = Header(...),
    db: Session = Depends(get_db)
):
    """Sets a 4-digit PIN code for quick biometric/PIN entry."""
    token = authorization.replace("Bearer ", "")
    payload = verify_token(token)
    user_id = int(payload["sub"])

    repo = UserRepository(db)
    repo.update_user_pin(user_id, get_password_hash(data.pin_code))
    return BaseResponse(data="PIN successfully set")

@router.get("/me", response_model=BaseResponse[UserDetailResponse])
def get_me(authorization: str = Header(...), db: Session = Depends(get_db)):
    """Returns details of the currently authenticated user."""
    token = authorization.replace("Bearer ", "")
    payload = verify_token(token)
    user_id = int(payload["sub"])

    repo = UserRepository(db)
    user = repo.get_user_by_id(user_id)
    if not user:
        return BaseResponse(success=False, error="User not found")
    return BaseResponse(data=UserDetailResponse.model_validate(user))
