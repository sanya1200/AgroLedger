from typing import List, Optional
from sqlalchemy.orm import Session, joinedload
from app.models.marketplace import Product, ProductCategory
from app.models.business_profile import BusinessProfile
from app.models.user import User
from app.schemas.marketplace import ProductCreate, ProductUpdate


class MarketplaceRepository:
    def __init__(self, db: Session):
        self.db = db

    def create_product(self, business_id: int, obj_in: ProductCreate) -> Product:
        db_obj = Product(
            **obj_in.model_dump(),
            business_id=business_id,
            is_active=True
        )
        self.db.add(db_obj)
        self.db.commit()
        self.db.refresh(db_obj)
        return db_obj

    def get_product_by_id(self, product_id: int) -> Optional[Product]:
        return self.db.query(Product).options(
            joinedload(Product.business).joinedload(BusinessProfile.user)
        ).filter(Product.id == product_id).first()

    def get_all_active_products(
        self,
        category: Optional[ProductCategory] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[Product]:
        query = self.db.query(Product).options(
            joinedload(Product.business).joinedload(BusinessProfile.user)
        ).filter(Product.is_active == True)
        if category:
            query = query.filter(Product.category == category)
        return query.offset(skip).limit(limit).all()

    def get_products_by_business(self, business_id: int) -> List[Product]:
        return self.db.query(Product).filter(Product.business_id == business_id).all()

    def update_product(self, db_obj: Product, obj_in: ProductUpdate) -> Product:
        update_data = obj_in.model_dump(exclude_unset=True)
        for field in update_data:
            setattr(db_obj, field, update_data[field])

        # Автоматическое скрытие товара, если остаток 0
        if db_obj.stock_quantity <= 0:
            db_obj.is_active = False

        self.db.add(db_obj)
        self.db.commit()
        self.db.refresh(db_obj)
        return db_obj

    def delete_product(self, product_id: int) -> bool:
        db_obj = self.get_product_by_id(product_id)
        if db_obj:
            # Используем мягкое удаление для сохранения истории
            db_obj.is_active = False
            self.db.commit()
            return True
        return False
