import enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, Enum, DateTime, ForeignKey, Float, Numeric
from sqlalchemy.orm import relationship
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

    id = Column(Integer, primary_key=True, index=True)
    business_id = Column(Integer, ForeignKey("business_profiles.id"), nullable=False)

    name = Column(String, nullable=False)
    animal_type = Column(Enum(AnimalType), nullable=False)
    status = Column(Enum(CycleStatus), default=CycleStatus.ACTIVE, nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)
    closed_at = Column(DateTime, nullable=True)

    # Relationships
    business = relationship("BusinessProfile", back_populates="calculation_cycles")
    expenses = relationship("Expense", back_populates="cycle", cascade="all, delete-orphan")
    incomes = relationship("Income", back_populates="cycle", cascade="all, delete-orphan")


class Expense(Base):
    __tablename__ = "expenses"

    id = Column(Integer, primary_key=True, index=True)
    cycle_id = Column(Integer, ForeignKey("calculation_cycles.id"), nullable=False)

    category = Column(Enum(ExpenseCategory), nullable=False)
    amount = Column(Numeric(precision=12, scale=2), nullable=False)
    description = Column(String, nullable=True)
    date = Column(DateTime, default=datetime.utcnow)

    # Relationships
    cycle = relationship("CalculationCycle", back_populates="expenses")


class Income(Base):
    __tablename__ = "incomes"

    id = Column(Integer, primary_key=True, index=True)
    cycle_id = Column(Integer, ForeignKey("calculation_cycles.id"), nullable=False)

    product_name = Column(String, nullable=False)
    quantity = Column(Float, nullable=False)
    amount = Column(Numeric(precision=12, scale=2), nullable=False)
    date = Column(DateTime, default=datetime.utcnow)

    # Relationships
    cycle = relationship("CalculationCycle", back_populates="incomes")
