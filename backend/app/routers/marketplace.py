from typing import List, Optional
from fastapi import APIRouter, Depends, status, Query
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.models.marketplace import ProductCategory
from app.schemas.marketplace import ProductCreate, ProductUpdate, ProductResponse
from app.services.marketplace_service import MarketplaceService

router = APIRouter()


@router.get("/products", response_model=List[ProductResponse])
def list_products(
    category: Optional[ProductCategory] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """
    Публичный каталог товаров. Доступен без авторизации.
    """
    service = MarketplaceService(db)
    return service.get_catalog(category, skip, limit)


@router.get("/products/{product_id}", response_model=ProductResponse)
def get_product(
    product_id: int,
    db: Session = Depends(get_db)
):
    """
    Просмотр карточки конкретного товара. Публичный эндпоинт.
    """
    service = MarketplaceService(db)
    return service.get_product(product_id)


@router.post("/products", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(
    product_in: ProductCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Создание объявления. Доступно только пользователям с ролью 'business'.
    """
    service = MarketplaceService(db)
    return service.create_product(current_user, product_in)


@router.put("/products/{product_id}", response_model=ProductResponse)
def update_product(
    product_id: int,
    product_in: ProductUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Обновление товара. Доступно только владельцу (бизнес-профилю).
    """
    service = MarketplaceService(db)
    return service.update_product(current_user, product_id, product_in)


@router.delete("/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(
    product_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Снятие товара с публикации (мягкое удаление). Доступно только владельцу.
    """
    service = MarketplaceService(db)
    service.remove_product(current_user, product_id)
    return None
