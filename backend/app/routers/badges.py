from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Badge, UserBadge, User
from app.schemas import BadgeResponse
from app.services.badge_service import get_badge_progress
from typing import List

router = APIRouter(prefix="/users/{user_id}/badges", tags=["badges"])

@router.get("", response_model=List[BadgeResponse])
def get_user_badges(user_id: str, db: Session = Depends(get_db)):
    all_badges = db.query(Badge).all()
    user_badges = db.query(UserBadge).filter(UserBadge.user_id == user_id).all()
    earned_badge_ids = {ub.badge_id for ub in user_badges}
    
    result = []
    for badge in all_badges:
        user_badge = next((ub for ub in user_badges if ub.badge_id == badge.id), None)
        progress = get_badge_progress(user_id, badge, db)
        
        result.append(BadgeResponse(
            id=badge.id,
            name=badge.name,
            description=badge.description,
            icon_emoji=badge.icon_emoji,
            tier=badge.tier,
            condition_type=badge.condition_type,
            condition_value=badge.condition_value,
            is_earned=badge.id in earned_badge_ids,
            earned_at=user_badge.earned_at if user_badge else None,
            progress=progress
        ))
    
    return result

@router.patch("/representative", response_model=dict)
def set_representative_badge(
    user_id: str,
    badge_id: str,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # 뱃지 존재 및 획득 여부 확인
    badge = db.query(Badge).filter(Badge.id == badge_id).first()
    if not badge:
        raise HTTPException(status_code=404, detail="Badge not found")
    
    if badge.tier not in ["Gold", "Silver"]:  # Gold 이상만 대표 설정 가능
        raise HTTPException(status_code=400, detail="Only Gold or Silver tier badges can be set as representative")
    
    user_badge = db.query(UserBadge).filter(
        UserBadge.user_id == user_id,
        UserBadge.badge_id == badge_id
    ).first()
    if not user_badge:
        raise HTTPException(status_code=400, detail="Badge not earned yet")
    
    user.representative_badge_id = badge_id
    db.commit()
    
    return {"message": "Representative badge updated", "badge_id": badge_id}

@router.get("/badges/{badge_id}", response_model=BadgeResponse)
def get_badge_detail(badge_id: str, user_id: str, db: Session = Depends(get_db)):
    badge = db.query(Badge).filter(Badge.id == badge_id).first()
    if not badge:
        raise HTTPException(status_code=404, detail="Badge not found")
    
    user_badge = db.query(UserBadge).filter(
        UserBadge.user_id == user_id,
        UserBadge.badge_id == badge_id
    ).first()
    
    progress = get_badge_progress(user_id, badge, db)
    
    return BadgeResponse(
        id=badge.id,
        name=badge.name,
        description=badge.description,
        icon_emoji=badge.icon_emoji,
        tier=badge.tier,
        condition_type=badge.condition_type,
        condition_value=badge.condition_value,
        is_earned=user_badge is not None,
        earned_at=user_badge.earned_at if user_badge else None,
        progress=progress
    )

