import enum
from datetime import datetime
from typing import Optional
from sqlalchemy import Integer, String, DateTime, ForeignKey, Boolean, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class TaskType(str, enum.Enum):
    VACCINATION = "vaccination"  # Вакцинация
    VET_CHECK = "vet_check"      # Ветеринарный осмотр
    BREEDING = "breeding"        # Осеменение/случка
    FEEDING = "feeding"          # Изменение рациона/кормление
    GENERAL = "general"          # Другие работы


class LivestockTask(Base):
    __tablename__ = "livestock_tasks"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    asset_id: Mapped[int] = mapped_column(Integer, ForeignKey("livestock_assets.id", ondelete="CASCADE"), nullable=False, index=True)
    
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(String(512), nullable=True)
    planned_date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    task_type: Mapped[str] = mapped_column(String(50), default="general", nullable=False)
    completed_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    # Relationship to the parent livestock group
    asset: Mapped["LivestockAsset"] = relationship("LivestockAsset", back_populates="tasks")
