import enum
from datetime import datetime
from typing import Optional, List
from sqlalchemy import Integer, String, DateTime, ForeignKey, Numeric, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class LivestockCategory(str, enum.Enum):
    CATTLE_KRS = "cattle_krs"
    SHEEP_MRS = "sheep_mrs"
    POULTRY_BIRDS = "poultry_birds"


class ProductType(str, enum.Enum):
    MILK = "milk"
    EGGS = "eggs"
    MEAT = "meat"
    LIVE_ANIMALS = "live_animals"


class LivestockAsset(Base):
    __tablename__ = "livestock_assets"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    category: Mapped[str] = mapped_column(String(50), nullable=False)
    breed: Mapped[str] = mapped_column(String(255), nullable=False)
    quantity: Mapped[int] = mapped_column(Integer, nullable=False)
    purchase_price: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    user: Mapped["User"] = relationship("User", back_populates="livestock_assets")
    expenses: Mapped[List["LivestockExpenses"]] = relationship(
        "LivestockExpenses", back_populates="asset", cascade="all, delete-orphan"
    )
    yields: Mapped[List["LivestockYield"]] = relationship(
        "LivestockYield", back_populates="asset", cascade="all, delete-orphan"
    )


class LivestockExpenses(Base):
    __tablename__ = "livestock_expenses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    asset_id: Mapped[int] = mapped_column(Integer, ForeignKey("livestock_assets.id"), nullable=False, index=True)
    feed_cost: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False, default=0)
    vet_cost: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False, default=0)
    utility_cost: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False, default=0)
    other_cost: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False, default=0)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    asset: Mapped["LivestockAsset"] = relationship("LivestockAsset", back_populates="expenses")


class LivestockYield(Base):
    __tablename__ = "livestock_yields"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    asset_id: Mapped[int] = mapped_column(Integer, ForeignKey("livestock_assets.id"), nullable=False, index=True)
    product_type: Mapped[str] = mapped_column(String(50), nullable=False)
    volume: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False)
    earnings: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    asset: Mapped["LivestockAsset"] = relationship("LivestockAsset", back_populates="yields")
