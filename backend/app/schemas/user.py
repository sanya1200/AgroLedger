from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, EmailStr, ConfigDict, Field, field_validator
from app.models.user import UserRole


class UserBase(BaseModel):
    email: EmailStr
    phone: Optional[str] = Field(None, pattern=r"^\+?[1-9]\d{1,14}$")
    role: UserRole = UserRole.BUYER

    @field_validator("role", mode="before")
    @classmethod
    def coerce_role(cls, v: Any) -> Any:
        if isinstance(v, str):
            return v.lower()
        return v


class UserCreate(UserBase):
    password: str = Field(..., min_length=8)


class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: Optional[datetime] = None
