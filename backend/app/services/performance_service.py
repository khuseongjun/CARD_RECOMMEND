from sqlalchemy.orm import Session
from app.models import CardPerformanceTier, Transaction, PerformanceClassification, CardProduct
from app.schemas import PerformanceSummary, TransactionWithClassification, PerformanceResponse
from datetime import datetime
from typing import List
from calendar import monthrange

def get_performance_summary(
    user_id: str,
    card_id: str,
    year: int,
    month: int,
    db: Session
) -> PerformanceResponse:
    """카드 실적 정보 조회"""
    # 해당 월의 시작일과 종료일
    start_date = datetime(year, month, 1)
    if month == 12:
        end_date = datetime(year + 1, 1, 1)
    else:
        end_date = datetime(year, month + 1, 1)
    
    # 실적 인정 거래 조회
    transactions = db.query(Transaction).filter(
        Transaction.user_id == user_id,
        Transaction.card_id == card_id,
        Transaction.approved_at >= start_date,
        Transaction.approved_at < end_date,
        Transaction.is_cancelled == False
    ).all()
    
    # 해당 월의 거래 ID 목록
    transaction_ids = [tx.id for tx in transactions]
    
    # 실적 분류 정보 조회
    classifications = db.query(PerformanceClassification).filter(
        PerformanceClassification.card_id == card_id,
        PerformanceClassification.transaction_id.in_(transaction_ids),
        PerformanceClassification.is_counted_for_performance == True
    ).all()
    
    # 현재 실적 계산
    current_spending = sum(c.performance_amount for c in classifications)
    
    # 티어 정보 조회
    tiers_data = db.query(CardPerformanceTier).filter(
        CardPerformanceTier.card_id == card_id
    ).order_by(CardPerformanceTier.min_amount).all()
    
    tiers = []
    current_tier = None
    next_tier = None
    
    for tier_data in tiers_data:
        tiers.append({
            "code": tier_data.tier_code,
            "label": tier_data.tier_label,
            "min_amount": tier_data.min_amount,
            "max_amount": tier_data.max_amount
        })
        
        # 현재 티어 찾기
        if (tier_data.min_amount <= current_spending and
            (tier_data.max_amount is None or current_spending < tier_data.max_amount)):
            current_tier = tier_data.tier_code
        
        # 다음 티어 찾기
        if (next_tier is None and
            (tier_data.max_amount is None or current_spending < tier_data.max_amount)):
            if tier_data.min_amount > current_spending:
                next_tier = tier_data.tier_code
    
    # 남은 금액 계산
    # 프론트엔드에서는 전체 목표(마지막 티어의 minAmount)까지의 남은 금액을 표시함
    if tiers_data:
        # 마지막 티어의 minAmount를 전체 목표로 사용
        last_tier = tiers_data[-1]
        target_amount = last_tier.min_amount
        remaining_amount = max(0, target_amount - current_spending)
    else:
        remaining_amount = 0
    
    summary = PerformanceSummary(
        current_spending=current_spending,
        remaining_amount=remaining_amount,  # 이미 max(0, ...)로 계산됨
        current_tier=current_tier,
        next_tier=next_tier,
        tiers=tiers
    )
    
    # 실적 인정/제외 내역 분류
    recognized = []
    excluded = []
    
    for tx in transactions:
        classification = next((c for c in classifications if c.transaction_id == tx.id), None)
        if not classification:
            continue
        
        tx_with_class = TransactionWithClassification(
            id=tx.id,
            merchant_name=tx.merchant_name,
            approved_at=tx.approved_at,
            amount=tx.amount,
            is_counted_for_performance=classification.is_counted_for_performance,
            is_counted_for_benefit=classification.is_counted_for_benefit,
            reason=classification.reason,
            performance_amount=classification.performance_amount
        )
        
        if classification.is_counted_for_performance:
            recognized.append(tx_with_class)
        else:
            excluded.append(tx_with_class)
    
    # 날짜순 정렬
    recognized.sort(key=lambda x: x.approved_at, reverse=True)
    excluded.sort(key=lambda x: x.approved_at, reverse=True)
    
    return PerformanceResponse(
        summary=summary,
        recognized=recognized,
        excluded=excluded
    )

