from datetime import datetime, timezone
from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.calendar import LivestockTask
from app.models.calculator import LivestockAsset
from app.schemas.calendar import TaskCreate, TaskUpdate


class CalendarRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_task(self, data: TaskCreate) -> LivestockTask:
        task = LivestockTask(
            asset_id=data.asset_id,
            title=data.title,
            description=data.description,
            planned_date=data.planned_date,
            task_type=data.task_type.value if hasattr(data.task_type, "value") else data.task_type,
            is_completed=False,
        )
        self.db.add(task)
        self.db.commit()
        self.db.refresh(task)
        return task

    def get_task_by_id(self, task_id: int) -> Optional[LivestockTask]:
        return self.db.query(LivestockTask).filter(LivestockTask.id == task_id).first()

    def get_tasks_by_user(self, user_id: int) -> List[LivestockTask]:
        return (
            self.db.query(LivestockTask)
            .join(LivestockAsset, LivestockTask.asset_id == LivestockAsset.id)
            .filter(LivestockAsset.user_id == user_id)
            .order_by(LivestockTask.planned_date.asc())
            .all()
        )

    def update_task(self, task: LivestockTask, data: TaskUpdate) -> LivestockTask:
        update_fields = data.model_dump(exclude_unset=True)
        for field, value in update_fields.items():
            if hasattr(value, "value"):
                value = value.value
            setattr(task, field, value)
            
            # If completing the task, record completion time
            if field == "is_completed":
                if value is True:
                    task.completed_at = datetime.now(timezone.utc)
                else:
                    task.completed_at = None

        self.db.commit()
        self.db.refresh(task)
        return task

    def delete_task(self, task: LivestockTask) -> None:
        self.db.delete(task)
        self.db.commit()
