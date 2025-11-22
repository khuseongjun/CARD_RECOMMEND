from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import UserCard, CardProduct, CardBenefit
from app.schemas import RecommendRequest, RecommendResponse
from typing import List, Optional
from datetime import datetime
from pydantic import BaseModel

router = APIRouter(prefix="/recommend", tags=["recommend"])

class RecommendRequestWithUserId(BaseModel):
    user_id: str
    merchant_category: str
    merchant_name: Optional[str] = None
    amount: int
    timestamp: datetime
    user_cards: List[str] = []

@router.post("", response_model=List[RecommendResponse])
def get_recommendations(
    request: RecommendRequestWithUserId,
    db: Session = Depends(get_db)
):
    """
    가맹점에 대한 최적 카드 추천
    
    Args:
        request: 추천 요청 정보 (가맹점 카테고리, 결제 금액, 사용자 카드 목록)
        user_id: 사용자 ID
    
    Returns:
        추천 카드 목록 (혜택 금액 순으로 정렬)
    """
    # 사용자 보유 카드 조회 (요청에 user_cards가 있으면 그것 사용, 없으면 DB에서 조회)
    if request.user_cards:
        user_card_ids = request.user_cards
    else:
        user_cards = db.query(UserCard).filter(UserCard.user_id == request.user_id).all()
        user_card_ids = [uc.card_id for uc in user_cards]
    
    if not user_card_ids:
        return []
    
    recommendations = []
    
    for card_id in user_card_ids:
        card = db.query(CardProduct).filter(CardProduct.id == card_id).first()
        if not card:
            continue
        
        # 해당 카테고리의 혜택 찾기
        benefits = db.query(CardBenefit).filter(
            CardBenefit.card_id == card_id,
            CardBenefit.category == request.merchant_category
        ).all()
        
        if not benefits:
            continue
        
        # 가장 큰 혜택 계산
        best_benefit = None
        best_benefit_amount = 0
        
        for benefit in benefits:
            if benefit.rate:
                benefit_amount = int(request.amount * benefit.rate)
                
                # 월 한도 체크 (단순화: 실제로는 월별 누적 확인 필요)
                if benefit.monthly_discount_limit:
                    benefit_amount = min(benefit_amount, benefit.monthly_discount_limit)
                
                if benefit_amount > best_benefit_amount:
                    best_benefit_amount = benefit_amount
                    best_benefit = benefit
        
        if best_benefit and best_benefit_amount > 0:
            # 조건 설명 생성
            conditions = []
            if best_benefit.previous_month_min_spending:
                conditions.append(f"전월실적 {best_benefit.previous_month_min_spending:,}원 이상")
            if best_benefit.monthly_discount_limit:
                conditions.append(f"월 최대 {best_benefit.monthly_discount_limit:,}원")
            if best_benefit.time_condition:
                time_cond = best_benefit.time_condition
                if isinstance(time_cond, dict):
                    conditions.append(f"야간 {time_cond.get('start', '')}–{time_cond.get('end', '')}")
            
            conditions_str = " / ".join(conditions) if conditions else None
            
            recommendations.append(RecommendResponse(
                card_id=card.id,
                card_name=card.name,
                merchant_name=request.merchant_name or "현재 위치",
                merchant_category=request.merchant_category,
                benefit_description=best_benefit.short_description or best_benefit.title,
                expected_benefit=best_benefit_amount,
                benefit_rate=best_benefit.rate,
                conditions=conditions_str
            ))
    
    # 혜택 금액 순으로 정렬
    recommendations.sort(key=lambda x: x.expected_benefit, reverse=True)
    
    # Top-N 반환 (보통 1-2개)
    return recommendations[:2]

