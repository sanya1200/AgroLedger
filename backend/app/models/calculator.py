import enum
from datetime import datetime
from typing import Optional, List
from sqlalchemy import Integer, String, DateTime, ForeignKey, Numeric, func, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class LivestockCategory(str, enum.Enum):
    CATTLE_MILK = "cattle_milk"
    CATTLE_MEAT = "cattle_meat"
    SHEEP = "sheep"
    GOATS = "goats"
    POULTRY_BROILERS = "poultry_broilers"
    POULTRY_LAYERS = "poultry_layers"
    HORSES = "horses"
    PIGS = "pigs"
    RABBITS = "rabbits"
    CAMELS = "camels"
    BEES = "bees"


# Detailed Expense Types
class FeedSubType(str, enum.Enum):
    ROUGHAGE_HAY = "roughage_hay"      # Грубые корма/Сено
    SILAGE = "silage"                  # Силос
    CONCENTRATES = "concentrates"      # Концентраты
    PRESTARTER = "prestarter"          # Престартер
    COMPOUND_FEED = "compound_feed"    # Комбикорм


class VetSubType(str, enum.Enum):
    VACCINATION = "vaccination"        # Вакцинация
    ANTIBIOTICS = "antibiotics"        # Антибиотики
    INSEMINATION = "insemination"      # Осеменение/Случка
    VITAMINS = "vitamins"              # Витамины
    VET_VISIT = "vet_visit"            # Вызов ветеринара


class UtilitySubType(str, enum.Enum):
    ELECTRICITY_INCUBATION = "elec_incubation"
    WATER_SUPPLY = "water"
    HEATING = "heating"
    VENTILATION = "ventilation"


class OtherSubType(str, enum.Enum):
    LOGISTICS = "logistics"
    TAGS_CHIPS = "tags_chips"
    SLAUGHTER_SHEARING = "slaughter_shearing"
    BEDDING = "bedding"


# Detailed Product Types (Yields)
class ProductSubType(str, enum.Enum):
    MILK = "milk"
    EGGS_COMMERCIAL = "eggs_commercial"
    EGGS_INCUBATION = "eggs_incubation"
    MEAT_CARCASS = "meat_carcass"
    DAY_OLD_CHICKS = "day_old_chicks"
    YOUNG_STOCK = "young_stock"
    WOOL = "wool"
    FAT_TAIL = "fat_tail"
    MANURE = "manure"
    LIVE_WEIGHT = "live_weight"
    HONEY = "honey"
    SHUBAT = "shubat"
    KUMYS = "kumys"
    PROPOLIS = "propolis"
    POLLEN = "pollen"
    FUR = "fur"


class LivestockAsset(Base):
    __tablename__ = "livestock_assets"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    category: Mapped[LivestockCategory] = mapped_column(Enum(LivestockCategory), nullable=False)
    breed: Mapped[str] = mapped_column(String(255), nullable=False)
    quantity: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False)
    purchase_price: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    user: Mapped["User"] = relationship("User", back_populates="livestock_assets")
    expenses: Mapped[List["LivestockExpenses"]] = relationship(
        "LivestockExpenses", back_populates="asset", cascade="all, delete-orphan"
    )
    yields: Mapped[List["LivestockYield"]] = relationship(
        "LivestockYield", back_populates="asset", cascade="all, delete-orphan"
    )


class LivestockExpenses(Base):
    __tablename__ = "livestock_expenses"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    asset_id: Mapped[int] = mapped_column(Integer, ForeignKey("livestock_assets.id"), nullable=False, index=True)

    feed_sub_type: Mapped[Optional[FeedSubType]] = mapped_column(Enum(FeedSubType), nullable=True)
    vet_sub_type: Mapped[Optional[VetSubType]] = mapped_column(Enum(VetSubType), nullable=True)
    utility_sub_type: Mapped[Optional[UtilitySubType]] = mapped_column(Enum(UtilitySubType), nullable=True)
    other_sub_type: Mapped[Optional[OtherSubType]] = mapped_column(Enum(OtherSubType), nullable=True)

    amount: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(String(512), nullable=True)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    asset: Mapped["LivestockAsset"] = relationship("LivestockAsset", back_populates="expenses")


class LivestockYield(Base):
    __tablename__ = "livestock_yields"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    asset_id: Mapped[int] = mapped_column(Integer, ForeignKey("livestock_assets.id"), nullable=False, index=True)

    product_sub_type: Mapped[ProductSubType] = mapped_column(Enum(ProductSubType), nullable=False)
    volume: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False)
    earnings: Mapped[float] = mapped_column(Numeric(precision=14, scale=2), nullable=False)
    date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    asset: Mapped["LivestockAsset"] = relationship("LivestockAsset", back_populates="yields")
