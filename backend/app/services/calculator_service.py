from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.user import User
from app.models.calculator import LivestockAsset, LivestockExpenses, LivestockYield, LivestockCategory, ProductSubType
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
    PredictiveForecastResponse,
)


class CalculatorService:
    def __init__(self, db: Session):
        self.db = db
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
        # Free version limit check
        if not user.premium_active:
            asset_count = self.db.query(LivestockAsset).filter(LivestockAsset.user_id == user.id).count()
            if asset_count >= 2:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="FREE_LIMIT_REACHED"
                )

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

    def create_yield(self, user: User, data: YieldCreate) -> YieldResponse:
        self._verify_asset_ownership(user, data.asset_id)
        record = self.repository.create_yield(data)
        return YieldResponse.model_validate(record)

    def get_analytics_summary(
        self, user_id: int, asset_id: Optional[int] = None
    ) -> CalculatorSummaryResponse:
        if asset_id is not None:
            asset = self.repository.get_asset_by_id(asset_id)
            if not asset or asset.user_id != user_id:
                raise HTTPException(status_code=404, detail="Asset not found")
            assets = [asset]
        else:
            assets = self.repository.get_assets_by_user(user_id)

        asset_ids = [asset.id for asset in assets]
        if not asset_ids:
            return CalculatorSummaryResponse(
                asset_id=asset_id,
                assets_count=0,
                initial_investment=Decimal("0"),
                total_feed_cost=Decimal("0"),
                total_vet_cost=Decimal("0"),
                total_utility_cost=Decimal("0"),
                total_other_cost=Decimal("0"),
                operating_expenses=Decimal("0"),
                total_costs=Decimal("0"),
                total_earnings=Decimal("0"),
                earnings_by_product={},
                net_profit=Decimal("0"),
                roi=0.0,
            )

        initial_investment = sum((Decimal(str(a.purchase_price)) for a in assets), Decimal("0"))

        # Calculate totals
        total_feed = self.db.query(func.sum(LivestockExpenses.amount)).filter(
            LivestockExpenses.asset_id.in_(asset_ids), LivestockExpenses.feed_sub_type.isnot(None)
        ).scalar() or Decimal("0")

        total_vet = self.db.query(func.sum(LivestockExpenses.amount)).filter(
            LivestockExpenses.asset_id.in_(asset_ids), LivestockExpenses.vet_sub_type.isnot(None)
        ).scalar() or Decimal("0")

        total_utility = self.db.query(func.sum(LivestockExpenses.amount)).filter(
            LivestockExpenses.asset_id.in_(asset_ids), LivestockExpenses.utility_sub_type.isnot(None)
        ).scalar() or Decimal("0")

        total_other = self.db.query(func.sum(LivestockExpenses.amount)).filter(
            LivestockExpenses.asset_id.in_(asset_ids), LivestockExpenses.other_sub_type.isnot(None)
        ).scalar() or Decimal("0")

        operating_expenses = total_feed + total_vet + total_utility + total_other
        total_costs = initial_investment + operating_expenses

        total_earnings = self.db.query(func.sum(LivestockYield.earnings)).filter(
            LivestockYield.asset_id.in_(asset_ids)
        ).scalar() or Decimal("0")

        yields = self.db.query(LivestockYield).filter(LivestockYield.asset_id.in_(asset_ids)).all()
        earnings_by_product = {}
        for y in yields:
            key = y.product_sub_type.value
            earnings_by_product[key] = earnings_by_product.get(key, Decimal("0")) + Decimal(str(y.earnings))

        net_profit = total_earnings - total_costs
        roi = float((net_profit / total_costs) * 100) if total_costs > 0 else 0.0

        return CalculatorSummaryResponse(
            asset_id=asset_id,
            assets_count=len(assets),
            initial_investment=initial_investment,
            total_feed_cost=total_feed,
            total_vet_cost=total_vet,
            total_utility_cost=total_utility,
            total_other_cost=total_other,
            operating_expenses=operating_expenses,
            total_costs=total_costs,
            total_earnings=total_earnings,
            earnings_by_product=earnings_by_product,
            net_profit=net_profit,
            roi=round(roi, 2),
        )

    def get_predictive_forecast(self, user: User, asset_id: int) -> PredictiveForecastResponse:
        asset = self._verify_asset_ownership(user, asset_id)

        summary = self.get_analytics_summary(user.id, asset_id=asset_id)
        total_earnings = summary.total_earnings

        fcr = None
        advice = "Продолжайте вести регулярный учет для формирования точного прогноза."
        break_even_date = None

        # FCR for Poultry Broilers
        if asset.category == LivestockCategory.POULTRY_BROILERS:
            total_feed_weight = self.db.query(func.sum(LivestockExpenses.amount)).filter(
                LivestockExpenses.asset_id == asset_id,
                LivestockExpenses.feed_sub_type.isnot(None)
            ).scalar() or 0

            total_meat_yield = self.db.query(func.sum(LivestockYield.volume)).filter(
                LivestockYield.asset_id == asset_id,
                LivestockYield.product_sub_type == ProductSubType.MEAT_CARCASS
            ).scalar() or 0

            if total_meat_yield > 0:
                fcr = float(Decimal(str(total_feed_weight)) / Decimal(str(total_meat_yield)))
                if fcr < 1.7:
                    advice = "Исключительные показатели! Рекомендуется забой на 42-45 день для максимизации прибыли."
                elif fcr < 2.0:
                    advice = "Хорошая конверсия корма. Соблюдайте текущий рацион."
                else:
                    advice = "Внимание: высокий расход корма. Проверьте качество комбикорма и температурный режим."

        # Break-even for Ruminants or Layers
        days_active = (datetime.now(timezone.utc) - asset.created_at).days or 1
        avg_daily_earnings = total_earnings / days_active

        if avg_daily_earnings > 0:
            remaining_to_cover = summary.total_costs - total_earnings
            if remaining_to_cover > 0:
                days_to_break_even = int(remaining_to_cover / avg_daily_earnings)
                break_even_date = datetime.now(timezone.utc) + timedelta(days=days_to_break_even)
                advice = f"Ожидаемый выход на окупаемость через {days_to_break_even} дн."
            else:
                advice = "Поздравляем! Данная группа уже приносит чистую прибыль."

        return PredictiveForecastResponse(
            asset_id=asset_id,
            category=asset.category,
            fcr=round(fcr, 2) if fcr else None,
            break_even_date=break_even_date,
            is_profitable=total_earnings > summary.total_costs,
            estimated_monthly_profit=avg_daily_earnings * 30,
            advice=advice
        )
