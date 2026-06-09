from datetime import datetime
from decimal import Decimal
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.repositories.calculator_repository import CalculatorRepository
from app.repositories.business_repository import BusinessRepository
from app.schemas.calculator import CalculationCycleCreate, ExpenseCreate, IncomeCreate, CycleAnalyticsResponse
from app.models.user import User
from app.models.calculator import CycleStatus


class CalculatorService:
    def __init__(self, db: Session):
        self.repository = CalculatorRepository(db)
        self.business_repo = BusinessRepository(db)

    def _get_business_id(self, user: User) -> int:
        profile = self.business_repo.get_by_user_id(user.id)
        if not profile:
            raise HTTPException(status_code=404, detail="Business profile not found")
        return profile.id

    def _verify_ownership(self, user: User, cycle_id: int):
        cycle = self.repository.get_cycle_by_id(cycle_id)
        if not cycle:
            raise HTTPException(status_code=404, detail="Cycle not found")

        business_id = self._get_business_id(user)
        if cycle.business_id != business_id:
            raise HTTPException(status_code=403, detail="Not enough permissions")
        return cycle

    def create_cycle(self, user: User, cycle_in: CalculationCycleCreate):
        business_id = self._get_business_id(user)
        return self.repository.create_cycle(business_id, cycle_in)

    def get_user_cycles(self, user: User):
        business_id = self._get_business_id(user)
        return self.repository.get_business_get_cycles(business_id)

    def add_expense(self, user: User, cycle_id: int, expense_in: ExpenseCreate):
        self._verify_ownership(user, cycle_id)
        return self.repository.add_expense(cycle_id, expense_in)

    def add_income(self, user: User, cycle_id: int, income_in: IncomeCreate):
        self._verify_ownership(user, cycle_id)
        return self.repository.add_income(cycle_id, income_in)

    def close_cycle(self, user: User, cycle_id: int):
        cycle = self._verify_ownership(user, cycle_id)
        from datetime import timezone
        update_data = {
            "status": CycleStatus.ARCHIVED,
            "closed_at": datetime.now(timezone.utc)
        }
        return self.repository.update_cycle(cycle, update_data)

    def get_analytics(self, user: User, cycle_id: int) -> CycleAnalyticsResponse:
        cycle = self._verify_ownership(user, cycle_id)
        expenses = self.repository.get_expenses(cycle_id)
        incomes = self.repository.get_incomes(cycle_id)

        total_expenses = sum(exp.amount for exp in expenses) if expenses else Decimal("0")
        total_incomes = sum(inc.amount for inc in incomes) if incomes else Decimal("0")

        net_profit = total_incomes - total_expenses

        # ROI = (Net Profit / Cost of Investment) * 100
        roi = 0.0
        if total_expenses > 0:
            roi = float((net_profit / total_expenses) * 100)

        return CycleAnalyticsResponse(
            total_expenses=total_expenses,
            total_incomes=total_incomes,
            net_profit=net_profit,
            ROI=round(roi, 2),
            status=cycle.status
        )
