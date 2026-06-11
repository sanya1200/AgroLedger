from datetime import datetime
from typing import Optional, Any
from decimal import Decimal
from pydantic import BaseModel, ConfigDict, Field, field_validator
from app.models.marketplace import ProductCategory


class ProductBase(BaseModel):
    title: str = Field(..., min_length=3, max_length=100)
    description: Optional[str] = None
    category: ProductCategory
    price_retail: Decimal = Field(..., ge=0)
    price_wholesale: Optional[Decimal] = Field(None, ge=0)
    wholesale_min_qty: float = Field(default=1.0, ge=0)
    stock_quantity: float = Field(default=0.0, ge=0)
    image_url: Optional[str] = None

    @field_validator("category", mode="before")
    @classmethod
    def coerce_category(cls, v: Any) -> Any:
        if isinstance(v, str):
            return v.lower()
        return v


class ProductCreate(ProductBase):
    pass


class ProductUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=3, max_length=100)
    description: Optional[str] = None
    category: Optional[ProductCategory] = None
    price_retail: Optional[Decimal] = Field(None, ge=0)
    price_wholesale: Optional[Decimal] = Field(None, ge=0)
    wholesale_min_qty: Optional[float] = Field(None, ge=0)
    stock_quantity: Optional[float] = Field(None, ge=0)
    image_url: Optional[str] = None
    is_active: Optional[bool] = None


class ProductResponse(ProductBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    business_id: int
    is_active: bool
    created_at: Optional[datetime] = None
    seller_name: Optional[str] = None
    seller_phone: Optional[str] = None
