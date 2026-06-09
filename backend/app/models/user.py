import enum
from datetime import datetime
from sqlalchemy import Column, Integer, String, Enum, DateTime
from sqlalchemy.orm import relationship
from app.core.database import Base


class UserRole(str, enum.Enum):
    BUYER = "buyer"
    BUSINESS = "business"


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    phone = Column(String, unique=True, index=True, nullable=True)
    role = Column(Enum(UserRole, native_enum=False), default=UserRole.BUYER, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    business_profile = relationship("BusinessProfile", back_populates="user", uselist=False)
