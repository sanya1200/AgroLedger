from typing import Optional, List
from sqlalchemy import String, Float, ForeignKey, Text, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class BusinessProfile(Base):
    __tablename__ = "business_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), unique=True, nullable=False)

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    bin_inn: Mapped[str] = mapped_column(String(20), index=True, nullable=False)
    location: Mapped[str] = mapped_column(String(255), nullable=False)
    rating: Mapped[float] = mapped_column(Float, default=5.0)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="business_profile")
    calculation_cycles: Mapped[List["CalculationCycle"]] = relationship("CalculationCycle", back_populates="business")
    products: Mapped[List["Product"]] = relationship("Product", back_populates="business")
