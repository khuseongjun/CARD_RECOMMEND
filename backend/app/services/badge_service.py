from sqlalchemy.orm import Session
from app.models import Badge, UserBadge, BenefitAggregation, Transaction, UserCard
from datetime import datetime, timedelta
from typing import List, Dict, Any
from sqlalchemy import func

def check_and_award_badges(user_id: str, db: Session) -> List[str]:
    """뱃지 조건 확인 및 수여"""
    all_badges = db.query(Badge).all()
    newly_earned = []
    
    for badge in all_badges:
        # 이미 획득한 뱃지인지 확인
        existing = db.query(UserBadge).filter(
            UserBadge.user_id == user_id,
            UserBadge.badge_id == badge.id
        ).first()
        
        if existing:
            continue
        
        # 조건 확인
        if check_badge_condition(user_id, badge, db):
            user_badge = UserBadge(
                user_id=user_id,
                badge_id=badge.id
            )
            db.add(user_badge)
            newly_earned.append(badge.id)
    
    db.commit()
    return newly_earned

def check_badge_condition(user_id: str, badge: Badge, db: Session) -> bool:
    """뱃지 조건 만족 여부 확인"""
    condition_type = badge.condition_type
    condition_value = badge.condition_value
    
    if condition_type == "benefit_amount_monthly":
        # 한 달 혜택 금액
        month_start = datetime.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        total_benefit = db.query(func.sum(BenefitAggregation.benefit_amount)).filter(
            BenefitAggregation.transaction_id.in_(
                db.query(Transaction.id).filter(
                    Transaction.user_id == user_id,
                    Transaction.approved_at >= month_start
                )
            )
        ).scalar() or 0
        
        return total_benefit >= condition_value.get("min_amount", 0)
    
    elif condition_type == "benefit_amount_3months":
        # 3개월 연속 혜택
        for i in range(3):
            month_start = (datetime.now() - timedelta(days=30*i)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            if i == 0:
                month_end = datetime.now()
            else:
                month_end = (datetime.now() - timedelta(days=30*(i-1))).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            
            total_benefit = db.query(func.sum(BenefitAggregation.benefit_amount)).filter(
                BenefitAggregation.transaction_id.in_(
                    db.query(Transaction.id).filter(
                        Transaction.user_id == user_id,
                        Transaction.approved_at >= month_start,
                        Transaction.approved_at < month_end
                    )
                )
            ).scalar() or 0
            
            if total_benefit < condition_value.get("min_amount", 0):
                return False
        
        return True
    
    elif condition_type == "card_count":
        # 등록 카드 수
        count = db.query(UserCard).filter(UserCard.user_id == user_id).count()
        return count >= condition_value.get("min_count", 0)
    
    elif condition_type == "transaction_count_category":
        # 카테고리별 거래 횟수
        month_start = datetime.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        count = db.query(Transaction).filter(
            Transaction.user_id == user_id,
            Transaction.merchant_category == condition_value.get("category"),
            Transaction.approved_at >= month_start,
            Transaction.is_cancelled == False
        ).count()
        
        return count >= condition_value.get("min_count", 0)
    
    elif condition_type == "recommendation_click_count":
        # 추천 클릭 횟수 (프론트엔드에서 추적 필요)
        # 여기서는 간단히 False 반환
        return False
    
    return False

def get_badge_progress(user_id: str, badge: Badge, db: Session) -> Dict[str, Any]:
    """뱃지 달성 진행도 계산"""
    condition_type = badge.condition_type
    condition_value = badge.condition_value
    
    if condition_type == "benefit_amount_monthly":
        month_start = datetime.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        total_benefit = db.query(func.sum(BenefitAggregation.benefit_amount)).filter(
            BenefitAggregation.transaction_id.in_(
                db.query(Transaction.id).filter(
                    Transaction.user_id == user_id,
                    Transaction.approved_at >= month_start
                )
            )
        ).scalar() or 0
        
        target = condition_value.get("min_amount", 1)
        return {
            "current": total_benefit,
            "target": target,
            "progress": min(total_benefit / target, 1.0) if target > 0 else 0
        }
    
    elif condition_type == "transaction_count_category":
        month_start = datetime.now().replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        count = db.query(Transaction).filter(
            Transaction.user_id == user_id,
            Transaction.merchant_category == condition_value.get("category"),
            Transaction.approved_at >= month_start,
            Transaction.is_cancelled == False
        ).count()
        
        target = condition_value.get("min_count", 1)
        return {
            "current": count,
            "target": target,
            "progress": min(count / target, 1.0) if target > 0 else 0
        }
    
    elif condition_type == "card_count":
        count = db.query(UserCard).filter(UserCard.user_id == user_id).count()
        target = condition_value.get("min_count", 1)
        return {
            "current": count,
            "target": target,
            "progress": min(count / target, 1.0) if target > 0 else 0
        }
    
    return {"current": 0, "target": 1, "progress": 0}

