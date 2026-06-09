from __future__ import annotations
import re
from datetime import datetime
from typing import Optional, Any, Generic, TypeVar, Union
from pydantic import BaseModel, EmailStr, Field, ConfigDict, field_validator

T = TypeVar('T')

class BaseResponse(BaseModel, Generic[T]):
    success: bool = True
    data: Optional[T] = None
    error: Optional[str] = None

class SignUpRequest(BaseModel):
    email: EmailStr
    phone: str = Field(..., description="Phone in international format, e.g. +77001234567")
    password: str = Field(..., min_length=8)
    full_name: Optional[str] = None
    role: str = Field(..., pattern="^(farmer_business|customer_buyer)$")

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, v: str) -> str:
        if not re.search(r'[A-Z]', v):
            raise ValueError("Password must contain at least one uppercase letter")
        if not re.search(r'\d', v):
            raise ValueError("Password must contain at least one digit")
        return v

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        if not re.match(r'^\+?[1-9]\d{1,14}$', v):
            raise ValueError("Invalid phone format")
        return v

class SignInRequest(BaseModel):
    email_or_phone: str
    password: str

class PinSetupRequest(BaseModel):
    pin_code: str = Field(..., pattern=r"^\d{4}$")

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "Bearer"
    expires_in: int = 900  # 15 min

class UserDetailResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: EmailStr
    phone: str
    full_name: Optional[str] = None
    role: str
    is_biometric_enabled: bool = False
    is_verified: bool = False
    created_at: Optional[datetime] = Field(default=None)
    has_business_profile: bool = False
