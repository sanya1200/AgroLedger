from decimal import Decimal
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.models.user import User
from app.models.calculator import LivestockAsset
from app.repositories.calculator_repository import CalculatorRepository
from app.schemas.calculator import (
    AssetCreate,
    AssetUpdate,
    AssetResponse,
    ExpenseCreate,
    ExpenseUpdate,
    ExpenseResponse,
    YieldCreate,
    YieldUpdate,
    YieldResponse,
    CalculatorSummaryResponse,
)


class CalculatorService:
    def __init__(self, db: Session):
        self.repository = CalculatorRepository(db)

    def _verify_asset_ownership(self, user: User, asset_id: int) -> LivestockAsset:
        asset = self.repository.get_asset_by_id(asset_id)
        if not asset:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Livestock asset not found",
            )
        if asset.user_id != user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions to access this asset",
            )
        return asset

    def create_asset(self, user: User, data: AssetCreate) -> AssetResponse:
        asset = self.repository.create_asset(user.id, data)
        return AssetResponse.model_validate(asset)

    def get_user_assets(self, user: User) -> List[AssetResponse]:
        assets = self.repository.get_assets_by_user(user.id)
        return [AssetResponse.model_validate(asset) for asset in assets]

    def get_asset(self, user: User, asset_id: int) -> AssetResponse:
        asset = self._verify_asset_ownership(user, asset_id)
        return AssetResponse.model_validate(asset)

    def update_asset(self, user: User, asset_id: int, data: AssetUpdate) -> AssetResponse:
        asset = self._verify_asset_ownership(user, asset_id)
        updated = self.repository.update_asset(asset, data)
        return AssetResponse.model_validate(updated)

    def delete_asset(self, user: User, asset_id: int) -> None:
        asset = self._verify_asset_ownership(user, asset_id)
        self.repository.delete_asset(asset)

    def create_expense(self, user: User, data: ExpenseCreate) -> ExpenseResponse:
        self._verify_asset_ownership(user, data.asset_id)
        expense = self.repository.create_expense(data)
        return ExpenseResponse.model_validate(expense)

    def get_expenses(self, user: User, asset_id: int) -> List[ExpenseResponse]:
        self._verify_asset_ownership(user, asset_id)
        expenses = self.repository.get_expenses_by_asset(asset_id)
        return [ExpenseResponse.model_validate(expense) for expense in expenses]

    def update_expense(self, user: User, expense_id: int, data: ExpenseUpdate) -> ExpenseResponse:
        expense = self.repository.get_expense_by_id(expense_id)
        if not expense:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expense record not found",
            )
        self._verify_asset_ownership(user, expense.asset_id)
        updated = self.repository.update_expense(expense, data)
        return ExpenseResponse.model_validate(updated)

    def delete_expense(self, user: User, expense_id: int) -> None:
        expense = self.repository.get_expense_by_id(expense_id)
        if not expense:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Expense record not found",
            )
        self._verify_asset_ownership(user, expense.asset_id)
        self.repository.delete_expense(expense)

    def create_yield(self, user: User, data: YieldCreate) -> YieldResponse:
        self._verify_asset_ownership(user, data.asset_id)
        record = self.repository.create_yield(data)
        return YieldResponse.model_validate(record)

    def get_yields(self, user: User, asset_id: int) -> List[YieldResponse]:
        self._verify_asset_ownership(user, asset_id)
        records = self.repository.get_yields_by_asset(asset_id)
        return [YieldResponse.model_validate(record) for record in records]

    def update_yield(self, user: User, yield_id: int, data: YieldUpdate) -> YieldResponse:
        record = self.repository.get_yield_by_id(yield_id)
        if not record:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Yield record not found",
            )
        self._verify_asset_ownership(user, record.asset_id)
        updated = self.repository.update_yield(record, data)
        return YieldResponse.model_validate(updated)

    def delete_yield(self, user: User, yield_id: int) -> None:
        record = self.repository.get_yield_by_id(yield_id)
        if not record:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Yield record not found",
            )
        self._verify_asset_ownership(user, record.asset_id)
        self.repository.delete_yield(record)

    def get_analytics_summary(
        self, user_id: int, asset_id: Optional[int] = None
    ) -> CalculatorSummaryResponse:
        if asset_id is not None:
            asset = self.repository.get_asset_by_id(asset_id)
            if not asset:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Livestock asset not found",
                )
            if asset.user_id != user_id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Not enough permissions to access this asset",
                )
            assets = [asset]
        else:
            assets = self.repository.get_assets_by_user(user_id)

        asset_ids = [asset.id for asset in assets]

        initial_investment = sum(
            (Decimal(str(asset.purchase_price)) for asset in assets),
            start=Decimal("0"),
        )

        expenses = self.repository.get_expenses_by_assets(asset_ids)
        yields = self.repository.get_yields_by_assets(asset_ids)

        total_feed_cost = Decimal("0")
        total_vet_cost = Decimal("0")
        total_utility_cost = Decimal("0")
        total_other_cost = Decimal("0")

        for expense in expenses:
            total_feed_cost += Decimal(str(expense.feed_cost))
            total_vet_cost += Decimal(str(expense.vet_cost))
            total_utility_cost += Decimal(str(expense.utility_cost))
            total_other_cost += Decimal(str(expense.other_cost))

        operating_expenses = (
            total_feed_cost + total_vet_cost + total_utility_cost + total_other_cost
        )
        total_costs = initial_investment + operating_expenses

        earnings_by_product: dict[str, Decimal] = {}
        total_earnings = Decimal("0")

        for record in yields:
            earnings = Decimal(str(record.earnings))
            total_earnings += earnings
            product_key = record.product_type
            earnings_by_product[product_key] = (
                earnings_by_product.get(product_key, Decimal("0")) + earnings
            )

        net_profit = total_earnings - total_costs

        roi = 0.0
        if total_costs > 0:
            roi = float((net_profit / total_costs) * 100)

        return CalculatorSummaryResponse(
            asset_id=asset_id,
            assets_count=len(assets),
            initial_investment=initial_investment,
            total_feed_cost=total_feed_cost,
            total_vet_cost=total_vet_cost,
            total_utility_cost=total_utility_cost,
            total_other_cost=total_other_cost,
            operating_expenses=operating_expenses,
            total_costs=total_costs,
            total_earnings=total_earnings,
            earnings_by_product=earnings_by_product,
            net_profit=net_profit,
            roi=round(roi, 2),
        )
