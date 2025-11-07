"""카드 혜택 추천 서비스"""
from typing import List, Optional, Dict
from sqlalchemy.orm import Session
from datetime import datetime, time as dt_time
from app.database import Card, Benefit, BenefitScope, TimeWindow, UserCard
from app.schemas import RecommendationResponse, RecommendRequest
import logging

logger = logging.getLogger(__name__)


class RecommendationService:
    """카드 혜택 추천 엔진"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_user_cards(self, user_id: int) -> List[int]:
        """사용자가 등록한 카드 ID 목록 조회"""
        user_cards = self.db.query(UserCard).filter(UserCard.user_id == user_id).all()
        return [uc.card_id for uc in user_cards]
    
    def filter_benefits_by_category(
        self,
        card_id: int,
        category: str,
        current_time: datetime
    ) -> List[Benefit]:
        """카테고리와 시간대에 맞는 혜택 필터링"""
        
        # 카드의 모든 혜택 조회
        benefits = (
            self.db.query(Benefit)
            .filter(Benefit.card_id == card_id)
            .all()
        )
        
        filtered_benefits = []
        
        for benefit in benefits:
            # 1. 유효기간 확인
            if benefit.valid_from and current_time.date() < benefit.valid_from:
                continue
            if benefit.valid_to and current_time.date() > benefit.valid_to:
                continue
            
            # 2. 카테고리 스코프 확인
            if not self._check_category_scope(benefit, category):
                continue
            
            # 3. 시간대 확인
            if not self._check_time_window(benefit, current_time):
                continue
            
            filtered_benefits.append(benefit)
        
        return filtered_benefits
    
    def _check_category_scope(self, benefit: Benefit, category: str) -> bool:
        """혜택이 해당 카테고리에 적용되는지 확인"""
        scopes = (
            self.db.query(BenefitScope)
            .filter(BenefitScope.benefit_id == benefit.benefit_id)
            .all()
        )
        
        if not scopes:
            # 스코프가 없으면 모든 카테고리에 적용
            return True
        
        # 포함/제외 로직
        included = False
        excluded = False
        
        for scope in scopes:
            if scope.scope_type == "CATEGORY" and scope.scope_value == category:
                if scope.include:
                    included = True
                else:
                    excluded = True
        
        # 제외가 우선
        if excluded:
            return False
        
        # 포함 스코프가 있으면 명시적으로 포함되어야 함
        if any(s.include for s in scopes):
            return included
        
        return True
    
    def _check_time_window(self, benefit: Benefit, current_time: datetime) -> bool:
        """시간대 제한 확인"""
        time_windows = (
            self.db.query(TimeWindow)
            .filter(TimeWindow.benefit_id == benefit.benefit_id)
            .all()
        )
        
        if not time_windows:
            # 시간 제한이 없으면 항상 적용
            return True
        
        current_hour_min = current_time.strftime("%H:%M")
        current_weekday = current_time.isoweekday()  # 1=월요일, 7=일요일
        
        for tw in time_windows:
            # 요일 확인
            if tw.days_of_week:
                allowed_days = [int(d) for d in tw.days_of_week.split("|")]
                if current_weekday not in allowed_days:
                    continue
            
            # 시간 확인 (야간 시간대 고려)
            start = tw.start_time
            end = tw.end_time
            
            if start <= end:
                # 일반 시간대 (예: 09:00 ~ 18:00)
                if start <= current_hour_min <= end:
                    return True
            else:
                # 야간 시간대 (예: 21:00 ~ 09:00)
                if current_hour_min >= start or current_hour_min <= end:
                    return True
        
        return False
    
    def calculate_expected_saving(
        self,
        benefit: Benefit,
        amount: int
    ) -> int:
        """예상 절약액 계산"""
        
        # 혜택 타입별 계산
        if benefit.benefit_type == "discount":
            # 할인율 적용
            if benefit.rate_pct:
                discount = int(amount * benefit.rate_pct / 100)
            elif benefit.flat_amount:
                discount = benefit.flat_amount
            else:
                discount = 0
            
            # 1회 할인 최대금액 적용
            if benefit.per_txn_discount_cap:
                discount = min(discount, benefit.per_txn_discount_cap)
            
            return discount
        
        elif benefit.benefit_type == "rebate":
            # 적립 (할인과 유사하게 계산)
            if benefit.rate_pct:
                rebate = int(amount * benefit.rate_pct / 100)
            elif benefit.flat_amount:
                rebate = benefit.flat_amount
            else:
                rebate = 0
            
            if benefit.per_txn_discount_cap:
                rebate = min(rebate, benefit.per_txn_discount_cap)
            
            return rebate
        
        else:
            return 0
    
    def recommend_cards(
        self,
        request: RecommendRequest
    ) -> List[RecommendationResponse]:
        """카드 추천"""
        
        logger.info(f"🎯 추천 요청: 카테고리={request.merchant_category}, 가맹점={request.merchant_name}")
        
        # 사용자 카드 목록
        user_card_ids = self.get_user_cards(request.user_id)
        
        if not user_card_ids:
            return []
        
        logger.info(f"📇 사용자 카드: {user_card_ids}")
        
        # 타임스탬프 파싱
        try:
            current_time = datetime.fromisoformat(request.timestamp.replace("Z", "+00:00"))
        except:
            current_time = datetime.now()
        
        recommendations = []
        
        for card_id in user_card_ids:
            # 카드 정보 조회
            card = self.db.query(Card).filter(Card.card_id == card_id).first()
            if not card:
                continue
            
            # 해당 카테고리에 적용 가능한 혜택 필터링
            benefits = self.filter_benefits_by_category(
                card_id,
                request.merchant_category,
                current_time
            )
            
            logger.info(f"💳 카드 {card.name}: {len(benefits)}개 혜택 매칭됨")
            
            for benefit in benefits:
                logger.info(f"  ✨ 혜택: {benefit.title}")
                # 예상 절약액 계산
                expected_saving = self.calculate_expected_saving(benefit, request.amount)
                
                # 최소 절약액 필터 (300원 이상)
                if expected_saving < 300:
                    continue
                
                # 조건 문구 생성
                conditions = self._generate_conditions(benefit, card)
                
                # 혜택 설명 생성
                benefit_desc = self._generate_benefit_desc(benefit, expected_saving)
                
                recommendation = RecommendationResponse(
                    card_id=card.card_id,
                    card_name=card.name,
                    card_issuer=card.issuer,
                    card_image_url=card.image_url,
                    benefit_title=benefit.title,
                    benefit_desc=benefit_desc,
                    expected_saving=expected_saving,
                    discount_rate=benefit.rate_pct,
                    conditions=conditions,
                    priority=benefit.priority
                )
                
                recommendations.append(recommendation)
        
        # 우선순위와 예상 절약액으로 정렬
        recommendations.sort(key=lambda x: (-x.expected_saving, x.priority))
        
        logger.info(f"🏆 최종 추천: {len(recommendations[:2])}개")
        for rec in recommendations[:2]:
            logger.info(f"  - {rec.card_name}: {rec.benefit_title} (절약: {rec.expected_saving}원)")
        
        # Top 2 반환
        return recommendations[:2]
    
    def _generate_conditions(self, benefit: Benefit, card: Card) -> List[str]:
        """조건 문구 생성"""
        conditions = []
        
        # 전월실적
        if card.min_spend_text:
            conditions.append(card.min_spend_text)
        
        # 월 한도
        if benefit.per_month:
            conditions.append(f"월 {benefit.per_month}회 한정")
        
        # 시간대 제한
        time_windows = (
            self.db.query(TimeWindow)
            .filter(TimeWindow.benefit_id == benefit.benefit_id)
            .all()
        )
        
        for tw in time_windows:
            if tw.start_time and tw.end_time:
                conditions.append(f"시간대: {tw.start_time}~{tw.end_time}")
        
        return conditions
    
    def _generate_benefit_desc(self, benefit: Benefit, expected_saving: int) -> str:
        """혜택 설명 생성"""
        desc_parts = []
        
        if benefit.rate_pct:
            desc_parts.append(f"{benefit.rate_pct}% 할인")
        
        if benefit.per_txn_discount_cap:
            desc_parts.append(f"최대 {benefit.per_txn_discount_cap:,}원")
        
        desc_parts.append(f"예상 절약: {expected_saving:,}원")
        
        return " / ".join(desc_parts)


def get_recommendation_service(db: Session) -> RecommendationService:
    """추천 서비스 팩토리"""
    return RecommendationService(db)

