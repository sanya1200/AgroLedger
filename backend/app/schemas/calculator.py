from datetime import datetime
from decimal import Decimal
from typing import Optional, Dict
from pydantic import BaseModel, ConfigDict, Field
from app.models.calculator import LivestockCategory, ProductType


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
    feed_cost: Decimal = Field(default=Decimal("0"), ge=0)
    vet_cost: Decimal = Field(default=Decimal("0"), ge=0)
    utility_cost: Decimal = Field(default=Decimal("0"), ge=0)
    other_cost: Decimal = Field(default=Decimal("0"), ge=0)
    date: datetime


class ExpenseUpdate(BaseModel):
    feed_cost: Optional[Decimal] = Field(None, ge=0)
    vet_cost: Optional[Decimal] = Field(None, ge=0)
    utility_cost: Optional[Decimal] = Field(None, ge=0)
    other_cost: Optional[Decimal] = Field(None, ge=0)
    date: Optional[datetime] = None


class ExpenseResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    asset_id: int
    feed_cost: Decimal
    vet_cost: Decimal
    utility_cost: Decimal
    other_cost: Decimal
    date: datetime

    @property
    def total_cost(self) -> Decimal:
        return self.feed_cost + self.vet_cost + self.utility_cost + self.other_cost


class YieldCreate(BaseModel):
    asset_id: int = Field(..., gt=0)
    product_type: ProductType
    volume: Decimal = Field(..., ge=0)
    earnings: Decimal = Field(..., ge=0)
    date: datetime


class YieldUpdate(BaseModel):
    product_type: Optional[ProductType] = None
    volume: Optional[Decimal] = Field(None, ge=0)
    earnings: Optional[Decimal] = Field(None, ge=0)
    date: Optional[datetime] = None


class YieldResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    asset_id: int
    product_type: ProductType
    volume: Decimal
    earnings: Decimal
    date: datetime


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
