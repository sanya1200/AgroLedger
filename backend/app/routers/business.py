from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.business_profile import BusinessProfileCreate, BusinessProfileResponse
from app.services.business_service import BusinessService

router = APIRouter()


@router.post("/", response_model=BusinessProfileResponse, status_code=status.HTTP_201_CREATED)
def create_business_profile(
    profile_in: BusinessProfileCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = BusinessService(db)
    return service.create_profile(current_user, profile_in)


@router.get("/me", response_model=BusinessProfileResponse)
def get_my_business_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = BusinessService(db)
    return service.get_my_profile(current_user)
