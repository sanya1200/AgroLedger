from datetime import datetime
from decimal import Decimal
from typing import Optional, Dict, List
from pydantic import BaseModel, ConfigDict, Field
from app.models.calculator import (
    LivestockCategory, ProductSubType, FeedSubType,
    VetSubType, UtilitySubType, OtherSubType
)


class AssetCreate(BaseModel):
    category: LivestockCategory
    breed: str = Field(..., min_length=1, max_length=255)
    quantity: float = Field(..., gt=0)
    purchase_price: Decimal = Field(..., ge=0)


class AssetUpdate(BaseModel):
    category: Optional[LivestockCategory] = None
    breed: Optional[str] = Field(None, min_length=1, max_length=255)
    quantity: Optional[float] = Field(None, gt=0)
    purchase_price: Optional[Decimal] = Field(None, ge=0)


class AssetResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    category: LivestockCategory
    breed: str
    quantity: float
    purchase_price: Decimal
    created_at: datetime


class ExpenseCreate(BaseModel):
    asset_id: int = Field(..., gt=0)
    feed_sub_type: Optional[FeedSubType] = None
    vet_sub_type: Optional[VetSubType] = None
    utility_sub_type: Optional[UtilitySubType] = None
    other_sub_type: Optional[OtherSubType] = None
    amount: Decimal = Field(..., gt=0)
    description: Optional[str] = None
    date: datetime


class ExpenseUpdate(BaseModel):
    feed_sub_type: Optional[FeedSubType] = None
    vet_sub_type: Optional[VetSubType] = None
    utility_sub_type: Optional[UtilitySubType] = None
    other_sub_type: Optional[OtherSubType] = None
    amount: Optional[Decimal] = Field(None, ge=0)
    description: Optional[str] = None
    date: Optional[datetime] = None


class ExpenseResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    asset_id: int
    feed_sub_type: Optional[FeedSubType] = None
    vet_sub_type: Optional[VetSubType] = None
    utility_sub_type: Optional[UtilitySubType] = None
    other_sub_type: Optional[OtherSubType] = None
    amount: Decimal
    description: Optional[str] = None
    date: datetime


class YieldCreate(BaseModel):
    asset_id: int = Field(..., gt=0)
    product_sub_type: ProductSubType
    volume: Decimal = Field(..., gt=0)
    earnings: Decimal = Field(..., ge=0)
    date: datetime


class YieldUpdate(BaseModel):
    product_sub_type: Optional[ProductSubType] = None
    volume: Optional[Decimal] = Field(None, ge=0)
    earnings: Optional[Decimal] = Field(None, ge=0)
    date: Optional[datetime] = None


class YieldResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    asset_id: int
    product_sub_type: ProductSubType
    volume: Decimal
    earnings: Decimal
    date: datetime


class PredictiveForecastResponse(BaseModel):
    asset_id: int
    category: LivestockCategory
    fcr: Optional[float] = None  # Feed Conversion Ratio
    break_even_date: Optional[datetime] = None
    is_profitable: bool
    estimated_monthly_profit: Decimal
    advice: str


class CalculatorSummaryResponse(BaseModel):
    asset_id: Optional[int] = None
    assets_count: int
    initial_investment: Decimal
    total_feed_cost: Decimal
    total_vet_cost: Decimal
    total_utility_cost: Decimal
    total_other_cost: Decimal
    operating_expenses: Decimal
    total_costs: Decimal
    total_earnings: Decimal
    earnings_by_product: Dict[str, Decimal]
    net_profit: Decimal
    roi: float
