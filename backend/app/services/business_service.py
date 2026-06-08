from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.repositories.business_repository import BusinessRepository
from app.schemas.business_profile import BusinessProfileCreate
from app.models.user import User, UserRole


class BusinessService:
    def __init__(self, db: Session):
        self.repository = BusinessRepository(db)

    def create_profile(self, user: User, profile_in: BusinessProfileCreate):
        if user.role != UserRole.BUSINESS:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only users with 'business' role can create a profile."
            )

        existing_profile = self.repository.get_by_user_id(user.id)
        if existing_profile:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User already has a business profile."
            )

        return self.repository.create(user.id, profile_in)

    def get_my_profile(self, user: User):
        profile = self.repository.get_by_user_id(user.id)
        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Business profile not found."
            )
        return profile
