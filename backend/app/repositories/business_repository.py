from typing import Optional
from sqlalchemy.orm import Session
from app.models.business_profile import BusinessProfile
from app.schemas.business_profile import BusinessProfileCreate, BusinessProfileUpdate


class BusinessRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_user_id(self, user_id: int) -> Optional[BusinessProfile]:
        return self.db.query(BusinessProfile).filter(BusinessProfile.user_id == user_id).first()

    def create(self, user_id: int, obj_in: BusinessProfileCreate) -> BusinessProfile:
        db_obj = BusinessProfile(
            **obj_in.model_dump(),
            user_id=user_id
        )
        self.db.add(db_obj)
        self.db.commit()
        self.db.refresh(db_obj)
        return db_obj

    def update(self, db_obj: BusinessProfile, obj_in: BusinessProfileUpdate) -> BusinessProfile:
        update_data = obj_in.model_dump(exclude_unset=True)
        for field in update_data:
            setattr(db_obj, field, update_data[field])
        self.db.add(db_obj)
        self.db.commit()
        self.db.refresh(db_obj)
        return db_obj
