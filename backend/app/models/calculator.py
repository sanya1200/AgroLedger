import enum
from datetime import datetime
from typing import Optional, List
from sqlalchemy import Integer, String, Enum, DateTime, ForeignKey, Float, Numeric, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class AnimalType(str, enum.Enum):
    POULTRY = "poultry"
    CATTLE = "cattle"
    LIVESTOCK = "livestock"
    FLIP = "flip"


class CycleStatus(str, enum.Enum):
    ACTIVE = "active"
    ARCHIVED = "archived"


class ExpenseCategory(str, enum.Enum):
    FEED = "feed"
    PURCHASE = "purchase"
    UTILITIES = "utilities"
    LOGISTICS = "logistics"
    VET = "vet"
    OTHER = "other"


class CalculationCycle(Base):
    __tablename__ = "calculation_cycles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    business_id: Mapped[int] = mapped_column(Integer, ForeignKey("business_profiles.id"), nullable=False)

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    animal_type: Mapped[AnimalType] = mapped_column(Enum(AnimalType), nullable=False)
    status: Mapped[CycleStatus] = mapped_column(Enum(CycleStatus), default=CycleStatus.ACTIVE, nullable=False)

    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    closed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    # Relationships
    business: Mapped["BusinessProfile"] = relationship("BusinessProfile", back_populates="calculation_cycles")
    expenses: Mapped[List["Expense"]] = relationship("Expense", back_populates="cycle", cascade="all, delete-orphan")
    incomes: Mapped[List["Income"]] = relationship("Income", back_populates="cycle", cascade="all, delete-orphan")


class Expense(Base):
    __tablename__ = "expenses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    cycle_id: Mapped[int] = mapped_column(Integer, ForeignKey("calculation_cycles.id"), nullable=False)

    category: Mapped[ExpenseCategory] = mapped_column(Enum(ExpenseCategory), nullable=False)
    amount: Mapped[float] = mapped_column(Numeric(precision=12, scale=2), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(String(512), nullable=True)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    cycle: Mapped["CalculationCycle"] = relationship("CalculationCycle", back_populates="expenses")


class Income(Base):
    __tablename__ = "incomes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    cycle_id: Mapped[int] = mapped_column(Integer, ForeignKey("calculation_cycles.id"), nullable=False)

    product_name: Mapped[str] = mapped_column(String(255), nullable=False)
    quantity: Mapped[float] = mapped_column(Float, nullable=False)
    amount: Mapped[float] = mapped_column(Numeric(precision=12, scale=2), nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    cycle: Mapped["CalculationCycle"] = relationship("CalculationCycle", back_populates="incomes")
