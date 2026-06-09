import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Union, Optional
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import HTTPException, status
from app.core.config import settings

# Using bcrypt for passwords and PINs
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plain text password against a hashed version."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Generates a bcrypt hash for the given password."""
    return pwd_context.hash(password)

def create_token_pair(user_id: int) -> dict:
    """
    Creates a pair of access and refresh tokens.
    Access token: 15 minutes.
    Refresh token: 30 days.
    """
    access_expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    refresh_expire = datetime.now(timezone.utc) + timedelta(days=30)

    jti = str(uuid.uuid4())

    access_token_payload = {
        "sub": str(user_id),
        "type": "access",
        "exp": access_expire
    }

    refresh_token_payload = {
        "sub": str(user_id),
        "type": "refresh",
        "jti": jti,
        "exp": refresh_expire
    }

    access_token = jwt.encode(
        access_token_payload,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )

    refresh_token = jwt.encode(
        refresh_token_payload,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "expires_in": 900,
        "jti": jti,
        "refresh_expires_at": refresh_expire
    }

def verify_token(token: str, expected_type: str = "access") -> dict:
    """
    Decodes and verifies a JWT token.
    Checks for expiration and correct type.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        if payload.get("type") != expected_type:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid token type: expected {expected_type}",
            )
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
