from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user, check_premium_status
from app.models.user import User
from app.schemas.auth import BaseResponse
from app.schemas.calculator import (
    AssetCreate,
    AssetResponse,
    ExpenseCreate,
    ExpenseResponse,
    YieldCreate,
    YieldResponse,
    CalculatorSummaryResponse,
    PredictiveForecastResponse,
)
from app.services.calculator_service import CalculatorService

router = APIRouter()


@router.post(
    "/assets",
    response_model=BaseResponse[AssetResponse],
    status_code=status.HTTP_201_CREATED,
)
def create_asset(
    data: AssetCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    service = CalculatorService(db)
    asset = service.create_asset(current_user, data)
    return BaseResponse(data=asset)


@router.get("/assets", response_model=BaseResponse[List[AssetResponse]])
def get_assets(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    service = CalculatorService(db)
    assets = service.get_user_assets(current_user)
    return BaseResponse(data=assets)


@router.post(
    "/expenses",
    response_model=BaseResponse[ExpenseResponse],
    status_code=status.HTTP_201_CREATED,
)
def create_expense(
    data: ExpenseCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    service = CalculatorService(db)
    expense = service.create_expense(current_user, data)
    return BaseResponse(data=expense)


@router.post(
    "/yields",
    response_model=BaseResponse[YieldResponse],
    status_code=status.HTTP_201_CREATED,
)
def create_yield(
    data: YieldCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    service = CalculatorService(db)
    record = service.create_yield(current_user, data)
    return BaseResponse(data=record)


@router.get("/summary", response_model=BaseResponse[CalculatorSummaryResponse])
def get_summary(
    asset_id: Optional[int] = Query(None, gt=0, description="Filter analytics by a specific asset"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    service = CalculatorService(db)
    summary = service.get_analytics_summary(current_user.id, asset_id=asset_id)
    return BaseResponse(data=summary)


@router.get("/predictive-forecast", response_model=BaseResponse[PredictiveForecastResponse])
def get_predictive_forecast(
    asset_id: int = Query(..., gt=0),
    db: Session = Depends(get_db),
    current_user: User = Depends(check_premium_status),
):
    """
    PREMIUM FEATURE: Calculates FCR for poultry or break-even date for other assets.
    """
    service = CalculatorService(db)
    forecast = service.get_predictive_forecast(current_user, asset_id)
    return BaseResponse(data=forecast)
