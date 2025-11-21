from sqlalchemy.orm import Session
from app.models import Transaction, UserCard, CardBenefit, PerformanceClassification, BenefitAggregation
from app.services.benefit_rule_engine import classify_performance, calculate_benefit
from datetime import datetime, timedelta
from typing import List
import uuid

def sync_transactions(user_id: str, transactions_data: List[dict], db: Session):
    """마이데이터에서 가져온 결제 내역을 동기화"""
    synced_count = 0
    
    for tx_data in transactions_data:
        # 이미 존재하는 거래인지 확인
        existing = db.query(Transaction).filter(
            Transaction.id == tx_data.get("id")
        ).first()
        
        if existing:
            continue
        
        # 새 거래 생성
        transaction = Transaction(
            id=tx_data.get("id", f"tx_{uuid.uuid4().hex[:8]}"),
            user_id=user_id,
            card_id=tx_data["card_id"],
            merchant_name=tx_data["merchant_name"],
            merchant_category=tx_data["merchant_category"],
            amount=tx_data["amount"],
            approved_at=datetime.fromisoformat(tx_data["approved_at"]) if isinstance(tx_data["approved_at"], str) else tx_data["approved_at"],
            is_offline_card=tx_data.get("is_offline_card", False),
            is_cancelled=tx_data.get("is_cancelled", False)
        )
        
        db.add(transaction)
        db.flush()
        
        # 실적 분류
        classification = classify_performance(transaction, db)
        db.add(classification)
        
        # 혜택 계산
        card_benefits = db.query(CardBenefit).filter(
            CardBenefit.card_id == transaction.card_id
        ).all()
        
        # 현재 월 실적 계산 (간단화)
        current_month_start = datetime.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        from sqlalchemy import func
        current_spending = db.query(func.sum(Transaction.amount)).filter(
            Transaction.user_id == user_id,
            Transaction.card_id == transaction.card_id,
            Transaction.approved_at >= current_month_start,
            Transaction.is_cancelled == False
        ).scalar() or 0
        
        benefit_aggregations = calculate_benefit(transaction, card_benefits, current_spending, db)
        for agg in benefit_aggregations:
            db.add(agg)
        
        synced_count += 1
    
    db.commit()
    return synced_count

