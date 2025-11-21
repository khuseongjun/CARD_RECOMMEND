from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import User
from app.services.recommendation_service import get_current_location_recommendation, get_missed_benefits
from app.schemas import CurrentRecommendationResponse, MissedBenefitResponse
from typing import List, Optional

router = APIRouter(prefix="/users/{user_id}/recommendations", tags=["recommendations"])

@router.get("/current", response_model=Optional[CurrentRecommendationResponse])
def get_current_recommendation(
    user_id: str,
    lat: float = Query(..., description="위도"),
    lng: float = Query(..., description="경도"),
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return get_current_location_recommendation(
        user_id=user_id,
        lat=lat,
        lng=lng,
        preferred_benefit_type=user.preferred_benefit_type,
        db=db
    )

@router.get("/missed", response_model=List[MissedBenefitResponse])
def get_missed_benefits_list(
    user_id: str,
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db)
):
    return get_missed_benefits(user_id, db, limit)

