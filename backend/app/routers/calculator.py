from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.calculator import (
    CalculationCycleCreate, CalculationCycleResponse,
    ExpenseCreate, ExpenseResponse,
    IncomeCreate, IncomeResponse,
    CycleAnalyticsResponse
)
from app.services.calculator_service import CalculatorService

router = APIRouter()


@router.post("/cycles", response_model=CalculationCycleResponse, status_code=status.HTTP_201_CREATED)
def create_cycle(
    cycle_in: CalculationCycleCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = CalculatorService(db)
    return service.create_cycle(current_user, cycle_in)


@router.get("/cycles", response_model=List[CalculationCycleResponse])
def get_cycles(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = CalculatorService(db)
    return service.get_user_cycles(current_user)


@router.post("/cycles/{cycle_id}/expenses", response_model=ExpenseResponse)
def add_expense(
    cycle_id: int,
    expense_in: ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = CalculatorService(db)
    return service.add_expense(current_user, cycle_id, expense_in)


@router.post("/cycles/{cycle_id}/incomes", response_model=IncomeResponse)
def add_income(
    cycle_id: int,
    income_in: IncomeCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = CalculatorService(db)
    return service.add_income(current_user, cycle_id, income_in)


@router.get("/cycles/{cycle_id}/analytics", response_model=CycleAnalyticsResponse)
def get_cycle_analytics(
    cycle_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = CalculatorService(db)
    return service.get_analytics(current_user, cycle_id)


@router.put("/cycles/{cycle_id}/close", response_model=CalculationCycleResponse)
def close_cycle(
    cycle_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = CalculatorService(db)
    return service.close_cycle(current_user, cycle_id)
