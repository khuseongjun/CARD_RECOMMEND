from sqlalchemy.orm import Session
from app.models import Transaction, CardBenefit, CardPerformanceTier, PerformanceClassification, BenefitAggregation
from datetime import datetime
from typing import List, Optional, Tuple

def classify_performance(transaction: Transaction, db: Session) -> PerformanceClassification:
    """거래의 실적 인정/제외 여부를 판정"""
    # 기본적으로 실적 인정 (실제로는 카드사별 규칙 적용)
    is_counted = True
    reason = "일반 가맹점 결제"
    
    # 취소 거래는 실적 제외
    if transaction.is_cancelled:
        is_counted = False
        reason = "취소 거래"
    
    # 오프라인 카드 사용 시 일부 제외 규칙 적용 가능
    if transaction.is_offline_card:
        # 예: 일부 카드는 오프라인 사용 시 실적 제외
        pass
    
    classification = PerformanceClassification(
        transaction_id=transaction.id,
        card_id=transaction.card_id,
        is_counted_for_performance=is_counted,
        is_counted_for_benefit=is_counted,
        reason=reason,
        performance_amount=transaction.amount if is_counted else 0
    )
    
    return classification

def calculate_benefit(
    transaction: Transaction,
    card_benefits: List[CardBenefit],
    current_month_spending: int,
    db: Session
) -> List[BenefitAggregation]:
    """거래에 대한 혜택 금액 계산"""
    aggregations = []
    
    # 거래 시간 추출
    transaction_time = transaction.approved_at.time()
    
    for benefit in card_benefits:
        # 카테고리 매칭
        if benefit.category != transaction.merchant_category:
            continue
        
        # 시간 조건 확인
        if benefit.time_condition:
            # JSON 필드이므로 dict로 접근 가능 (SQLAlchemy가 자동 변환)
            time_condition = benefit.time_condition if isinstance(benefit.time_condition, dict) else {}
            if time_condition.get("start") and time_condition.get("end"):
                try:
                    start_time = datetime.strptime(time_condition["start"], "%H:%M").time()
                    end_time = datetime.strptime(time_condition["end"], "%H:%M").time()
                    
                    # 시간 범위 체크 (예: 21:00 ~ 09:00 같은 경우)
                    if start_time > end_time:  # 자정을 넘는 경우
                        if not (transaction_time >= start_time or transaction_time <= end_time):
                            continue
                    else:
                        if not (start_time <= transaction_time <= end_time):
                            continue
                except (ValueError, KeyError):
                    # 시간 조건 파싱 실패 시 건너뛰기
                    pass
        
        # 혜택 금액 계산
        if benefit.rate:
            base_benefit = int(transaction.amount * benefit.rate)
        else:
            base_benefit = 0
        
        # 월 한도 확인
        # monthly_usage_limit: 월 최대 이용금액 (거래 금액 기준)
        # monthly_discount_limit: 월 최대 할인금액 (혜택 금액 기준)
        benefit_amount = base_benefit
        
        # 이용 금액 한도 체크
        if benefit.monthly_usage_limit is not None:
            # 이미 사용한 금액 확인 (간단화: 실제로는 월별 집계 필요)
            # 여기서는 현재 거래 금액이 한도 이내인지만 확인
            if transaction.amount > benefit.monthly_usage_limit:
                # 거래 금액이 한도를 초과하면 혜택 제한
                benefit_amount = int(benefit.monthly_usage_limit * benefit.rate) if benefit.rate else 0
        
        # 할인 금액 한도 체크
        if benefit.monthly_discount_limit is not None:
            # 혜택 금액이 월 할인 한도를 초과하지 않도록 제한
            # 실제로는 월별 누적 할인 금액을 확인해야 하지만, 여기서는 단건 제한만 적용
            benefit_amount = min(benefit_amount, benefit.monthly_discount_limit)
        
        if benefit_amount > 0:
            aggregation = BenefitAggregation(
                transaction_id=transaction.id,
                card_id=transaction.card_id,
                card_benefit_id=benefit.id,
                benefit_type=benefit.benefit_type,
                benefit_amount=benefit_amount
            )
            aggregations.append(aggregation)
            # 첫 번째 매칭되는 혜택만 적용 (중복 방지)
            break
    
    return aggregations

