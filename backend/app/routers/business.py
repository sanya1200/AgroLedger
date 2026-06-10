from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.auth import BaseResponse
from app.schemas.business_profile import BusinessProfileCreate, BusinessProfileResponse, BusinessProfileUpdate
from app.services.business_service import BusinessService

router = APIRouter()


@router.post("/", response_model=BaseResponse[BusinessProfileResponse], status_code=status.HTTP_201_CREATED)
def create_business_profile(
    profile_in: BusinessProfileCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = BusinessService(db)
    profile = service.create_profile(current_user, profile_in)
    return BaseResponse(data=profile)


@router.patch("/", response_model=BaseResponse[BusinessProfileResponse])
def update_business_profile(
    profile_in: BusinessProfileUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = BusinessService(db)
    profile = service.update_profile(current_user, profile_in)
    return BaseResponse(data=profile)


@router.get("/me", response_model=BaseResponse[BusinessProfileResponse])
def get_my_business_profile(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    service = BusinessService(db)
    profile = service.get_my_profile(current_user)
    return BaseResponse(data=profile)
