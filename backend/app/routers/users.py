from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import User
from app.schemas import UserResponse, UserUpdate
from typing import List

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/{user_id}", response_model=UserResponse)
def get_user(user_id: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.patch("/{user_id}/preferences", response_model=UserResponse)
def update_user_preferences(user_id: str, preferences: UserUpdate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if preferences.name is not None:
        user.name = preferences.name
    if preferences.preferred_benefit_type is not None:
        user.preferred_benefit_type = preferences.preferred_benefit_type
    if preferences.representative_badge_id is not None:
        user.representative_badge_id = preferences.representative_badge_id
    
    db.commit()
    db.refresh(user)
    return user

