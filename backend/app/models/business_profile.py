from sqlalchemy import Column, Integer, String, Float, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.core.database import Base


class BusinessProfile(Base):
    __tablename__ = "business_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)

    name = Column(String, nullable=False)
    bin_inn = Column(String, index=True, nullable=False)
    location = Column(String, nullable=False)
    rating = Column(Float, default=5.0)
    description = Column(Text, nullable=True)

    # Relationships
    user = relationship("User", back_populates="business_profile")
    calculation_cycles = relationship("CalculationCycle", back_populates="business")
    products = relationship("Product", back_populates="business")
