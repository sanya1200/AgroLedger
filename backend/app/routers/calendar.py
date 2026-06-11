from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.models.calculator import LivestockAsset
from app.schemas.auth import BaseResponse
from app.schemas.calendar import TaskCreate, TaskUpdate, TaskResponse
from app.repositories.calendar_repository import CalendarRepository
from app.repositories.calculator_repository import CalculatorRepository

router = APIRouter()


def _verify_asset_ownership(db: Session, user: User, asset_id: int) -> LivestockAsset:
    calc_repo = CalculatorRepository(db)
    asset = calc_repo.get_asset_by_id(asset_id)
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


def _verify_task_ownership(db: Session, user: User, task_id: int):
    cal_repo = CalendarRepository(db)
    task = cal_repo.get_task_by_id(task_id)
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Calendar task not found",
        )
    # Verify that the asset linked to this task belongs to the user
    _verify_asset_ownership(db, user, task.asset_id)
    return task


@router.get("/tasks", response_model=BaseResponse[List[TaskResponse]])
def list_tasks(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Получить все ветеринарные и календарные задачи текущего пользователя.
    """
    cal_repo = CalendarRepository(db)
    tasks = cal_repo.get_tasks_by_user(current_user.id)
    return BaseResponse(data=tasks)


@router.post("/tasks", response_model=BaseResponse[TaskResponse], status_code=status.HTTP_201_CREATED)
def create_task(
    data: TaskCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Создать новую ветеринарную/календарную задачу для группы животных.
    """
    _verify_asset_ownership(db, current_user, data.asset_id)
    cal_repo = CalendarRepository(db)
    task = cal_repo.create_task(data)
    return BaseResponse(data=task)


@router.patch("/tasks/{task_id}", response_model=BaseResponse[TaskResponse])
def update_task(
    task_id: int,
    data: TaskUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Обновить/выполнить ветеринарную или календарную задачу.
    """
    task = _verify_task_ownership(db, current_user, task_id)
    cal_repo = CalendarRepository(db)
    updated = cal_repo.update_task(task, data)
    return BaseResponse(data=updated)


@router.delete("/tasks/{task_id}", response_model=BaseResponse[None])
def delete_task(
    task_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Удалить календарную задачу.
    """
    task = _verify_task_ownership(db, current_user, task_id)
    cal_repo = CalendarRepository(db)
    cal_repo.delete_task(task)
    return BaseResponse(data=None)
