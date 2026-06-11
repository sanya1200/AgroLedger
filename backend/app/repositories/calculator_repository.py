from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.calculator import LivestockAsset, LivestockExpenses, LivestockYield
from app.schemas.calculator import (
    AssetCreate,
    AssetUpdate,
    ExpenseCreate,
    ExpenseUpdate,
    YieldCreate,
    YieldUpdate,
)


class CalculatorRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_asset(self, user_id: int, data: AssetCreate) -> LivestockAsset:
        asset = LivestockAsset(
            user_id=user_id,
            category=data.category.value if hasattr(data.category, "value") else data.category,
            breed=data.breed,
            quantity=data.quantity,
            purchase_price=data.purchase_price,
        )
        self.db.add(asset)
        self.db.commit()
        self.db.refresh(asset)
        return asset

    def get_asset_by_id(self, asset_id: int) -> Optional[LivestockAsset]:
        return self.db.query(LivestockAsset).filter(LivestockAsset.id == asset_id).first()

    def get_assets_by_user(self, user_id: int) -> List[LivestockAsset]:
        return (
            self.db.query(LivestockAsset)
            .filter(LivestockAsset.user_id == user_id)
            .order_by(LivestockAsset.created_at.desc())
            .all()
        )

    def update_asset(self, asset: LivestockAsset, data: AssetUpdate) -> LivestockAsset:
        update_fields = data.model_dump(exclude_unset=True)
        for field, value in update_fields.items():
            if hasattr(value, "value"):
                value = value.value
            setattr(asset, field, value)
        self.db.commit()
        self.db.refresh(asset)
        return asset

    def delete_asset(self, asset: LivestockAsset) -> None:
        self.db.delete(asset)
        self.db.commit()

    def create_expense(self, data: ExpenseCreate) -> LivestockExpenses:
        expense = LivestockExpenses(
            asset_id=data.asset_id,
            feed_sub_type=data.feed_sub_type.value if hasattr(data.feed_sub_type, "value") else data.feed_sub_type,
            vet_sub_type=data.vet_sub_type.value if hasattr(data.vet_sub_type, "value") else data.vet_sub_type,
            utility_sub_type=data.utility_sub_type.value if hasattr(data.utility_sub_type, "value") else data.utility_sub_type,
            other_sub_type=data.other_sub_type.value if hasattr(data.other_sub_type, "value") else data.other_sub_type,
            amount=data.amount,
            description=data.description,
            date=data.date,
        )
        self.db.add(expense)
        self.db.commit()
        self.db.refresh(expense)
        return expense

    def get_expense_by_id(self, expense_id: int) -> Optional[LivestockExpenses]:
        return self.db.query(LivestockExpenses).filter(LivestockExpenses.id == expense_id).first()

    def get_expenses_by_asset(self, asset_id: int) -> List[LivestockExpenses]:
        return (
            self.db.query(LivestockExpenses)
            .filter(LivestockExpenses.asset_id == asset_id)
            .order_by(LivestockExpenses.date.desc())
            .all()
        )

    def get_expenses_by_assets(self, asset_ids: List[int]) -> List[LivestockExpenses]:
        if not asset_ids:
            return []
        return (
            self.db.query(LivestockExpenses)
            .filter(LivestockExpenses.asset_id.in_(asset_ids))
            .order_by(LivestockExpenses.date.desc())
            .all()
        )

    def update_expense(self, expense: LivestockExpenses, data: ExpenseUpdate) -> LivestockExpenses:
        for field, value in data.model_dump(exclude_unset=True).items():
            if hasattr(value, "value"):
                value = value.value
            setattr(expense, field, value)
        self.db.commit()
        self.db.refresh(expense)
        return expense

    def delete_expense(self, expense: LivestockExpenses) -> None:
        self.db.delete(expense)
        self.db.commit()

    def create_yield(self, data: YieldCreate) -> LivestockYield:
        record = LivestockYield(
            asset_id=data.asset_id,
            product_sub_type=data.product_sub_type.value if hasattr(data.product_sub_type, "value") else data.product_sub_type,
            volume=data.volume,
            earnings=data.earnings,
            date=data.date,
        )
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        return record

    def get_yield_by_id(self, yield_id: int) -> Optional[LivestockYield]:
        return self.db.query(LivestockYield).filter(LivestockYield.id == yield_id).first()

    def get_yields_by_asset(self, asset_id: int) -> List[LivestockYield]:
        return (
            self.db.query(LivestockYield)
            .filter(LivestockYield.asset_id == asset_id)
            .order_by(LivestockYield.date.desc())
            .all()
        )

    def get_yields_by_assets(self, asset_ids: List[int]) -> List[LivestockYield]:
        if not asset_ids:
            return []
        return (
            self.db.query(LivestockYield)
            .filter(LivestockYield.asset_id.in_(asset_ids))
            .order_by(LivestockYield.date.desc())
            .all()
        )

    def update_yield(self, record: LivestockYield, data: YieldUpdate) -> LivestockYield:
        for field, value in data.model_dump(exclude_unset=True).items():
            if hasattr(value, "value"):
                value = value.value
            setattr(record, field, value)
        self.db.commit()
        self.db.refresh(record)
        return record

    def delete_yield(self, record: LivestockYield) -> None:
        self.db.delete(record)
        self.db.commit()
