from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field
from app.models.calendar import TaskType


class TaskCreate(BaseModel):
    asset_id: int = Field(..., gt=0)
    title: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=512)
    planned_date: datetime
    task_type: TaskType = TaskType.GENERAL


class TaskUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = Field(None, max_length=512)
    planned_date: Optional[datetime] = None
    is_completed: Optional[bool] = None
    task_type: Optional[TaskType] = None


class TaskResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    asset_id: int
    title: str
    description: Optional[str] = None
    planned_date: datetime
    is_completed: bool
    task_type: str
    completed_at: Optional[datetime] = None
    created_at: datetime
