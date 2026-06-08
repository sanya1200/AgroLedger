from datetime import datetime
from typing import Optional
from decimal import Decimal
from pydantic import BaseModel, ConfigDict
from app.models.calculator import AnimalType, CycleStatus, ExpenseCategory


class ExpenseBase(BaseModel):
    category: ExpenseCategory
    amount: Decimal
    description: Optional[str] = None


class ExpenseCreate(ExpenseBase):
    pass


class ExpenseResponse(ExpenseBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    cycle_id: int
    date: datetime


class IncomeBase(BaseModel):
    product_name: str
    quantity: float
    amount: Decimal


class IncomeCreate(IncomeBase):
    pass


class IncomeResponse(IncomeBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    cycle_id: int
    date: datetime


class CalculationCycleBase(BaseModel):
    name: str
    animal_type: AnimalType


class CalculationCycleCreate(CalculationCycleBase):
    pass


class CalculationCycleUpdate(BaseModel):
    name: Optional[str] = None
    status: Optional[CycleStatus] = None


class CalculationCycleResponse(CalculationCycleBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    business_id: int
    status: CycleStatus
    created_at: datetime
    closed_at: Optional[datetime] = None


class CycleAnalyticsResponse(BaseModel):
    total_expenses: Decimal
    total_incomes: Decimal
    net_profit: Decimal
    ROI: float
    status: CycleStatus
