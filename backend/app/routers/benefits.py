from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.database import get_db
from app.models import BenefitAggregation, Transaction, CardProduct, UserCard
from app.schemas import BenefitSummaryResponse, BenefitRankResponse
from typing import List, Dict, Any
from datetime import datetime, timedelta

router = APIRouter(prefix="/users/{user_id}/benefits", tags=["benefits"])

@router.get("/summary", response_model=BenefitSummaryResponse)
def get_benefit_summary(
    user_id: str,
    month: str = Query(..., description="YYYY-MM 형식"),
    db: Session = Depends(get_db)
):
    # 월 파싱
    year, month_num = map(int, month.split("-"))
    start_date = datetime(year, month_num, 1)
    if month_num == 12:
        end_date = datetime(year + 1, 1, 1)
    else:
        end_date = datetime(year, month_num + 1, 1)
    
    # 해당 월 거래 조회
    transactions = db.query(Transaction).filter(
        Transaction.user_id == user_id,
        Transaction.approved_at >= start_date,
        Transaction.approved_at < end_date,
        Transaction.is_cancelled == False
    ).all()
    
    transaction_ids = [tx.id for tx in transactions]
    
    # 혜택 집계
    total_benefit = db.query(func.sum(BenefitAggregation.benefit_amount)).filter(
        BenefitAggregation.transaction_id.in_(transaction_ids)
    ).scalar() or 0
    
    # 카드별 혜택
    card_benefits = db.query(
        BenefitAggregation.card_id,
        func.sum(BenefitAggregation.benefit_amount).label("total")
    ).filter(
        BenefitAggregation.transaction_id.in_(transaction_ids)
    ).group_by(BenefitAggregation.card_id).all()
    
    card_benefit_list = []
    for card_id, benefit_amount in card_benefits:
        card = db.query(CardProduct).filter(CardProduct.id == card_id).first()
        card_benefit_list.append({
            "card_id": card_id,
            "card_name": card.name if card else "",
            "benefit_amount": int(benefit_amount) if benefit_amount else 0
        })
    
    return BenefitSummaryResponse(
        total_benefit=int(total_benefit),
        card_benefits=card_benefit_list
    )

@router.get("/rank", response_model=BenefitRankResponse)
def get_benefit_rank(
    user_id: str,
    period: str = Query("1y", description="1y, 6m, 3m"),
    db: Session = Depends(get_db)
):
    # 기간 계산
    if period == "1y":
        start_date = datetime.now() - timedelta(days=365)
    elif period == "6m":
        start_date = datetime.now() - timedelta(days=180)
    elif period == "3m":
        start_date = datetime.now() - timedelta(days=90)
    else:
        start_date = datetime.now() - timedelta(days=365)
    
    # 사용자 거래 및 혜택
    transactions = db.query(Transaction).filter(
        Transaction.user_id == user_id,
        Transaction.approved_at >= start_date,
        Transaction.is_cancelled == False
    ).all()
    
    transaction_ids = [tx.id for tx in transactions]
    total_spending = sum(tx.amount for tx in transactions)
    
    total_benefit = db.query(func.sum(BenefitAggregation.benefit_amount)).filter(
        BenefitAggregation.transaction_id.in_(transaction_ids)
    ).scalar() or 0
    
    discount_rate = (total_benefit / total_spending * 100) if total_spending > 0 else 0
    
    # 간단한 퍼센타일 계산 (실제로는 전체 사용자 데이터 필요)
    percentile = min(100, max(0, 100 - (discount_rate * 10)))
    
    return BenefitRankResponse(
        percentile=percentile,
        total_spending_1y=int(total_spending),
        total_benefit_1y=int(total_benefit),
        discount_rate=round(discount_rate, 2),
        average_discount_rate=1.3  # 하드코딩 (실제로는 전체 평균 계산)
    )

