from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.calculator import CalculationCycle, Expense, Income, CycleStatus
from app.schemas.calculator import CalculationCycleCreate, ExpenseCreate, IncomeCreate


class CalculatorRepository:
    def __init__(self, db: Session):
        self.db = db

    # Cycles
    def create_cycle(self, business_id: int, obj_in: CalculationCycleCreate) -> CalculationCycle:
        db_obj = CalculationCycle(
            **obj_in.model_dump(),
            business_id=business_id,
            status=CycleStatus.ACTIVE
        )
        self.db.add(db_obj)
        self.db.commit()
        self.db.refresh(db_obj)
        return db_obj

    def get_cycle_by_id(self, cycle_id: int) -> Optional[CalculationCycle]:
        return self.db.query(CalculationCycle).filter(CalculationCycle.id == cycle_id).first()

    def get_business_get_cycles(self, business_id: int) -> List[CalculationCycle]:
        return self.db.query(CalculationCycle).filter(CalculationCycle.id == business_id).all() # Fix: should be business_id
        # Correction for the above: business_id field check
        return self.db.query(CalculationCycle).filter(CalculationCycle.business_id == business_id).all()

    def update_cycle(self, db_obj: CalculationCycle, update_data: dict) -> CalculationCycle:
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        self.db.add(db_obj)
        self.db.commit()
        self.db.refresh(db_obj)
        return db_obj

    # Expenses
    def add_expense(self, cycle_id: int, obj_in: ExpenseCreate) -> Expense:
        db_obj = Expense(**obj_in.model_dump(), cycle_id=cycle_id)
        self.db.add(db_obj)
        self.db.commit()
        self.db.refresh(db_obj)
        return db_obj

    def get_expenses(self, cycle_id: int) -> List[Expense]:
        return self.db.query(Expense).filter(Expense.cycle_id == cycle_id).all()

    # Incomes
    def add_income(self, cycle_id: int, obj_in: IncomeCreate) -> Income:
        db_obj = Income(**obj_in.model_dump(), cycle_id=cycle_id)
        self.db.add(db_obj)
        self.db.commit()
        self.db.refresh(db_obj)
        return db_obj

    def get_incomes(self, cycle_id: int) -> List[Income]:
        return self.db.query(Income).filter(Income.cycle_id == cycle_id).all()
