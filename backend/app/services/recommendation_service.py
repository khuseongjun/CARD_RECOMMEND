from sqlalchemy.orm import Session
from app.models import UserCard, CardProduct, CardBenefit, Transaction
from app.schemas import CurrentRecommendationResponse, MissedBenefitResponse
from typing import List, Optional
from datetime import datetime, timedelta
import requests

def get_current_location_recommendation(
    user_id: str,
    lat: float,
    lng: float,
    preferred_benefit_type: Optional[str],
    db: Session
) -> Optional[CurrentRecommendationResponse]:
    """위치 기반 최대 혜택 카드 추천"""
    # 사용자 보유 카드 조회
    user_cards = db.query(UserCard).filter(UserCard.user_id == user_id).all()
    if not user_cards:
        return None
    
    # 카카오 로컬 API로 주변 가맹점 조회 (실제 구현 시 API 키 필요)
    # 여기서는 모의 데이터 사용
    nearby_merchants = [
        {"name": "스타벅스 강남점", "category": "cafe", "distance": 50},
        {"name": "CGV 강남", "category": "movie", "distance": 200},
    ]
    
    if not nearby_merchants:
        return None
    
    # 가장 가까운 가맹점 선택
    nearest_merchant = min(nearby_merchants, key=lambda x: x["distance"])
    
    # 각 카드별 예상 혜택 계산
    best_card = None
    best_benefit = 0
    best_benefit_desc = ""
    
    # 가정 결제 금액
    assumed_amount = 10000
    
    for user_card in user_cards:
        card = db.query(CardProduct).filter(CardProduct.id == user_card.card_id).first()
        if not card:
            continue
        
        # 해당 카테고리 혜택 찾기
        benefits = db.query(CardBenefit).filter(
            CardBenefit.card_id == card.id,
            CardBenefit.category == nearest_merchant["category"]
        ).all()
        
        if not benefits:
            continue
        
        # 가장 큰 혜택 선택
        for benefit in benefits:
            if benefit.rate:
                expected_benefit = int(assumed_amount * benefit.rate)
            else:
                expected_benefit = 0
            
            # 선호 혜택 타입 우선순위
            priority = 1.0
            if preferred_benefit_type and benefit.benefit_type == preferred_benefit_type:
                priority = 1.5
            
            adjusted_benefit = expected_benefit * priority
            
            if adjusted_benefit > best_benefit:
                best_benefit = expected_benefit
                best_card = card
                best_benefit_desc = benefit.short_description or benefit.title
    
    if not best_card:
        return None
    
    return CurrentRecommendationResponse(
        card_id=best_card.id,
        card_name=best_card.name,
        merchant_name=nearest_merchant["name"],
        benefit_description=best_benefit_desc,
        expected_benefit=best_benefit
    )

def get_missed_benefits(user_id: str, db: Session, limit: int = 10) -> List[MissedBenefitResponse]:
    """놓친 혜택 계산"""
    # 최근 1개월 거래 조회
    one_month_ago = datetime.now() - timedelta(days=30)
    transactions = db.query(Transaction).filter(
        Transaction.user_id == user_id,
        Transaction.approved_at >= one_month_ago,
        Transaction.is_cancelled == False
    ).all()
    
    # 사용자 보유 카드 목록
    user_cards = db.query(UserCard).filter(UserCard.user_id == user_id).all()
    user_card_ids = [uc.card_id for uc in user_cards]
    
    missed_benefits = []
    
    for tx in transactions:
        # 실제 사용한 카드의 혜택
        actual_benefits = db.query(CardBenefit).filter(
            CardBenefit.card_id == tx.card_id,
            CardBenefit.category == tx.merchant_category
        ).all()
        
        actual_benefit_amount = 0
        for benefit in actual_benefits:
            if benefit.rate:
                actual_benefit_amount += int(tx.amount * benefit.rate)
        
        # 다른 카드로 결제했을 때의 혜택 계산
        best_alternative_benefit = 0
        best_alternative_card = None
        
        for card_id in user_card_ids:
            if card_id == tx.card_id:
                continue
            
            alternative_benefits = db.query(CardBenefit).filter(
                CardBenefit.card_id == card_id,
                CardBenefit.category == tx.merchant_category
            ).all()
            
            alternative_benefit_amount = 0
            for benefit in alternative_benefits:
                if benefit.rate:
                    alternative_benefit_amount += int(tx.amount * benefit.rate)
            
            if alternative_benefit_amount > best_alternative_benefit:
                best_alternative_benefit = alternative_benefit_amount
                best_alternative_card = db.query(CardProduct).filter(CardProduct.id == card_id).first()
        
        # 놓친 혜택이 있는 경우
        if best_alternative_benefit > actual_benefit_amount:
            missed_amount = best_alternative_benefit - actual_benefit_amount
            used_card = db.query(CardProduct).filter(CardProduct.id == tx.card_id).first()
            
            missed_benefits.append(MissedBenefitResponse(
                transaction_id=tx.id,
                date=tx.approved_at,
                merchant_name=tx.merchant_name,
                used_card_id=tx.card_id,
                used_card_name=used_card.name if used_card else "",
                recommended_card_id=best_alternative_card.id if best_alternative_card else "",
                recommended_card_name=best_alternative_card.name if best_alternative_card else "",
                missed_amount=missed_amount
            ))
    
    # 놓친 금액이 큰 순으로 정렬
    missed_benefits.sort(key=lambda x: x.missed_amount, reverse=True)
    
    return missed_benefits[:limit]

