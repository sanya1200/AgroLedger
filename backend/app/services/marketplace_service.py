from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.repositories.marketplace_repository import MarketplaceRepository
from app.repositories.business_repository import BusinessRepository
from app.schemas.marketplace import ProductCreate, ProductUpdate
from app.models.user import User, UserRole
from app.models.marketplace import ProductCategory


class MarketplaceService:
    def __init__(self, db: Session):
        self.repository = MarketplaceRepository(db)
        self.business_repo = BusinessRepository(db)

    def _get_business_id(self, user: User) -> int:
        profile = self.business_repo.get_by_user_id(user.id)
        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Business profile not found. Please create a profile first."
            )
        return profile.id

    def _verify_ownership(self, user: User, product_id: int):
        product = self.repository.get_product_by_id(product_id)
        if not product:
            raise HTTPException(status_code=404, detail="Product not found")

        business_id = self._get_business_id(user)
        if product.business_id != business_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to manage this product."
            )
        return product

    def create_product(self, user: User, product_in: ProductCreate):
        # Universal access: removed role checks
        business_id = self._get_business_id(user)
        return self.repository.create_product(business_id, product_in)

    def get_catalog(self, category: Optional[ProductCategory], skip: int, limit: int):
        return self.repository.get_all_active_products(category, skip, limit)

    def get_product(self, product_id: int):
        product = self.repository.get_product_by_id(product_id)
        if not product:
            raise HTTPException(status_code=404, detail="Product not found")
        return product

    def update_product(self, user: User, product_id: int, product_in: ProductUpdate):
        db_product = self._verify_ownership(user, product_id)
        return self.repository.update_product(db_product, product_in)

    def remove_product(self, user: User, product_id: int):
        self._verify_ownership(user, product_id)
        return self.repository.delete_product(product_id)
