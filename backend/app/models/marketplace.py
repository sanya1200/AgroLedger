import enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, Enum, DateTime, ForeignKey, Float, Numeric, Boolean, Text
from sqlalchemy.orm import relationship
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

    id = Column(Integer, primary_key=True, index=True)
    business_id = Column(Integer, ForeignKey("business_profiles.id"), nullable=False)

    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    category = Column(Enum(ProductCategory), nullable=False)

    price_retail = Column(Numeric(precision=12, scale=2), nullable=False)
    price_wholesale = Column(Numeric(precision=12, scale=2), nullable=True)
    wholesale_min_qty = Column(Float, default=1.0)

    image_url = Column(String, nullable=True)
    stock_quantity = Column(Float, default=0.0)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    business = relationship("BusinessProfile", back_populates="products")
