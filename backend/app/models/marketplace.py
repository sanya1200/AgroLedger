import enum
from datetime import datetime, timezone
from typing import Optional
from sqlalchemy import String, Enum, DateTime, ForeignKey, Float, Numeric, Boolean, Text, Integer, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class ProductCategory(str, enum.Enum):
    ANIMALS = "animals"
    MEAT = "meat"
    EGGS = "eggs"
    MILK = "milk"
    FEED = "feed"
    EQUIPMENT = "equipment"


class Product(Base):
    __tablename__ = "products"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    business_id: Mapped[int] = mapped_column(Integer, ForeignKey("business_profiles.id"), nullable=False)

    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    category: Mapped[ProductCategory] = mapped_column(Enum(ProductCategory), nullable=False)

    price_retail: Mapped[float] = mapped_column(Numeric(precision=12, scale=2), nullable=False)
    price_wholesale: Mapped[Optional[float]] = mapped_column(Numeric(precision=12, scale=2), nullable=True)
    wholesale_min_qty: Mapped[float] = mapped_column(Float, default=1.0)

    image_url: Mapped[Optional[str]] = mapped_column(String(1024), nullable=True)
    stock_quantity: Mapped[float] = mapped_column(Float, default=0.0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    business: Mapped["BusinessProfile"] = relationship("BusinessProfile", back_populates="products")
