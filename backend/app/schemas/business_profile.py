from typing import Optional
from pydantic import BaseModel, ConfigDict


class BusinessProfileBase(BaseModel):
    name: str
    bin_inn: str
    location: str
    description: Optional[str] = None


class BusinessProfileCreate(BusinessProfileBase):
    pass


class BusinessProfileUpdate(BaseModel):
    name: Optional[str] = None
    bin_inn: Optional[str] = None
    location: Optional[str] = None
    description: Optional[str] = None


class BusinessProfileResponse(BusinessProfileBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    rating: float
