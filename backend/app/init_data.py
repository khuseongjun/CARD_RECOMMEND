from sqlalchemy.orm import Session
from app.database import SessionLocal, engine, Base
from app.models import (
    User, CardProduct, CardPerformanceTier, CardBenefit,
    Badge, UserCard, Transaction, PerformanceClassification, BenefitAggregation, UserBadge
)
from datetime import datetime, timedelta
import uuid
from sqlalchemy import func

def init_sample_data():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # ===== 사용자 생성 =====
        user = db.query(User).filter(User.id == "user_123").first()
        if not user:
            user = User(
                id="user_123",
                name="김테스트",
                email="test@cardbuddy.com",
                preferred_benefit_type="discount"
            )
            db.add(user)
            db.commit()
        
        # ===== 10개 카드 생성 =====
        cards_data = [
            {
                "id": "kb_mr_life",
                "name": "KB국민 MR.Life",
                "issuer": "KB국민",
                "card_type": ["credit", "check"],
                "benefit_types": ["discount"],
                "annual_fee_domestic": 10000,
                "annual_fee_international": 13000,
                "min_monthly_spending": 500000,
            },
            {
                "id": "shinhan_deep_dream",
                "name": "신한 Deep Dream",
                "issuer": "신한카드",
                "card_type": ["credit"],
                "benefit_types": ["discount", "cashback"],
                "annual_fee_domestic": 12000,
                "annual_fee_international": 15000,
                "min_monthly_spending": 300000,
            },
            {
                "id": "toss_check",
                "name": "토스뱅크 체크카드",
                "issuer": "토스뱅크",
                "card_type": ["check"],
                "benefit_types": ["cashback"],
                "annual_fee_domestic": 0,
                "annual_fee_international": 0,
                "min_monthly_spending": 0,
            },
            {
                "id": "kakao_check",
                "name": "카카오뱅크 체크카드",
                "issuer": "카카오뱅크",
                "card_type": ["check"],
                "benefit_types": ["cashback"],
                "annual_fee_domestic": 0,
                "annual_fee_international": 0,
                "min_monthly_spending": 0,
            },
            {
                "id": "hana_travelog",
                "name": "하나카드 트래블로그",
                "issuer": "하나카드",
                "card_type": ["credit"],
                "benefit_types": ["discount", "mileage"],
                "annual_fee_domestic": 15000,
                "annual_fee_international": 18000,
                "min_monthly_spending": 300000,
            },
            {
                "id": "samsung_taptap",
                "name": "삼성 taptap O",
                "issuer": "삼성카드",
                "card_type": ["credit"],
                "benefit_types": ["discount"],
                "annual_fee_domestic": 10000,
                "annual_fee_international": 13000,
                "min_monthly_spending": 300000,
            },
            {
                "id": "woori_myway",
                "name": "우리카드 My Way",
                "issuer": "우리카드",
                "card_type": ["credit"],
                "benefit_types": ["discount"],
                "annual_fee_domestic": 12000,
                "annual_fee_international": 15000,
                "min_monthly_spending": 400000,
            },
            {
                "id": "hyundai_m",
                "name": "현대카드 M",
                "issuer": "현대카드",
                "card_type": ["credit"],
                "benefit_types": ["points"],
                "annual_fee_domestic": 15000,
                "annual_fee_international": 18000,
                "min_monthly_spending": 500000,
            },
            {
                "id": "nh_chaeum",
                "name": "NH농협 채움",
                "issuer": "NH농협",
                "card_type": ["credit", "check"],
                "benefit_types": ["discount"],
                "annual_fee_domestic": 8000,
                "annual_fee_international": 10000,
                "min_monthly_spending": 300000,
            },
            {
                "id": "ibk_one",
                "name": "IBK기업 One",
                "issuer": "IBK기업은행",
                "card_type": ["credit"],
                "benefit_types": ["discount"],
                "annual_fee_domestic": 10000,
                "annual_fee_international": 12000,
                "min_monthly_spending": 400000,
            },
        ]
        
        for card_data in cards_data:
            existing_card = db.query(CardProduct).filter(CardProduct.id == card_data["id"]).first()
            if not existing_card:
                card = CardProduct(**card_data)
                db.add(card)
        
        db.commit()
        
        # ===== 실적 구간 생성 =====
        tier_configs = [
            ("kb_mr_life", [
                ("T1", "1구간", 100000, 299999),
                ("T2", "2구간", 300000, 499999),
                ("T3", "3구간", 500000, None),
            ]),
            ("shinhan_deep_dream", [
                ("T1", "1구간", 100000, 299999),
                ("T2", "2구간", 300000, None),
            ]),
            ("hana_travelog", [
                ("T1", "1구간", 100000, 299999),
                ("T2", "2구간", 300000, None),
            ]),
            ("samsung_taptap", [
                ("T1", "1구간", 100000, 299999),
                ("T2", "2구간", 300000, None),
            ]),
            ("woori_myway", [
                ("T1", "1구간", 100000, 399999),
                ("T2", "2구간", 400000, None),
            ]),
            ("hyundai_m", [
                ("T1", "1구간", 100000, 499999),
                ("T2", "2구간", 500000, None),
            ]),
            ("nh_chaeum", [
                ("T1", "1구간", 100000, 299999),
                ("T2", "2구간", 300000, None),
            ]),
            ("ibk_one", [
                ("T1", "1구간", 100000, 399999),
                ("T2", "2구간", 400000, None),
            ]),
        ]
        
        for card_id, tiers in tier_configs:
            for tier_code, tier_label, min_amount, max_amount in tiers:
                existing_tier = db.query(CardPerformanceTier).filter(
                    CardPerformanceTier.card_id == card_id,
                    CardPerformanceTier.tier_code == tier_code
                ).first()
                if not existing_tier:
                    tier = CardPerformanceTier(
                        card_id=card_id,
                        tier_code=tier_code,
                        tier_label=tier_label,
                        min_amount=min_amount,
                        max_amount=max_amount
                    )
                    db.add(tier)
        
        db.commit()
        
        # ===== 카드 혜택 생성 =====
        _create_kb_mr_life_benefits(db)
        _create_shinhan_deep_dream_benefits(db)
        _create_toss_check_benefits(db)
        _create_kakao_check_benefits(db)
        _create_hana_travelog_benefits(db)
        _create_samsung_taptap_benefits(db)
        _create_woori_myway_benefits(db)
        _create_hyundai_m_benefits(db)
        _create_nh_chaeum_benefits(db)
        _create_ibk_one_benefits(db)
        
        db.commit()
        
        # ===== 뱃지 생성 =====
        badges_data = [
            {
                "id": "benefit_hunter",
                "name": "혜택 헌터",
                "description": "한 달 동안 10,000원 이상 혜택을 받았어요",
                "icon_emoji": "🎯",
                "tier": "Bronze",
                "condition_type": "benefit_amount_monthly",
                "condition_value": {"min_amount": 10000}
            },
            {
                "id": "saving_master",
                "name": "절약 마스터",
                "description": "3개월 연속 5,000원 이상 혜택을 받았어요",
                "icon_emoji": "💰",
                "tier": "Silver",
                "condition_type": "benefit_consecutive_months",
                "condition_value": {"min_amount": 5000, "months": 3}
            },
            {
                "id": "card_collector",
                "name": "카드 컬렉터",
                "description": "5개 이상의 카드를 등록했어요",
                "icon_emoji": "💳",
                "tier": "Gold",
                "condition_type": "card_count",
                "condition_value": {"min_count": 5}
            },
            {
                "id": "first_card",
                "name": "첫 카드",
                "description": "첫 번째 카드를 등록했어요",
                "icon_emoji": "🎉",
                "tier": "Bronze",
                "condition_type": "card_count",
                "condition_value": {"min_count": 1}
            },
            {
                "id": "spending_master",
                "name": "소비 마스터",
                "description": "한 달에 100만원 이상 사용했어요",
                "icon_emoji": "💸",
                "tier": "Silver",
                "condition_type": "monthly_spending",
                "condition_value": {"min_amount": 1000000}
            },
            {
                "id": "benefit_expert",
                "name": "혜택 전문가",
                "description": "한 달에 50,000원 이상 혜택을 받았어요",
                "icon_emoji": "🏆",
                "tier": "Gold",
                "condition_type": "benefit_amount_monthly",
                "condition_value": {"min_amount": 50000}
            },
        ]
        
        for badge_data in badges_data:
            existing_badge = db.query(Badge).filter(Badge.id == badge_data["id"]).first()
            if not existing_badge:
                badge = Badge(**badge_data)
                db.add(badge)
        
        db.commit()
        
        # ===== 사용자 카드 등록 =====
        user_cards_to_register = [
            ("kb_mr_life", "주력 카드"),
            ("shinhan_deep_dream", "외식 전용"),
            ("toss_check", "체크카드"),
        ]
        
        for card_id, nickname in user_cards_to_register:
            user_card = db.query(UserCard).filter(
                UserCard.user_id == "user_123",
                UserCard.card_id == card_id
            ).first()
            if not user_card:
                user_card = UserCard(
                    user_id="user_123",
                    card_id=card_id,
                    nickname=nickname
                )
                db.add(user_card)
        
        db.commit()
        
        # ===== 샘플 거래 내역 추가 =====
        _add_sample_transactions(db, "user_123", "kb_mr_life")
        _add_sample_transactions(db, "user_123", "shinhan_deep_dream")
        _add_sample_transactions(db, "user_123", "toss_check")
        
        # ===== 사용자 뱃지 획득 =====
        first_card_badge = db.query(UserBadge).filter(
            UserBadge.user_id == "user_123",
            UserBadge.badge_id == "first_card"
        ).first()
        if not first_card_badge:
            first_card_badge = UserBadge(
                user_id="user_123",
                badge_id="first_card",
                earned_at=datetime.now()
            )
            db.add(first_card_badge)
        
        db.commit()
        print("✅ 초기 데이터 삽입 완료! (10개 카드 포함)")
    except Exception as e:
        db.rollback()
        print(f"❌ 에러 발생: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()


# ===== KB국민 MR.Life 혜택 =====
def _create_kb_mr_life_benefits(db: Session):
    excluded_merchants_common = [
        "무이자할부", "정부지원금", "대학등록금", "국세/지방세/공과금",
        "상품권/선불카드", "교통카드충전", "고속버스", "아파트관리비",
        "수수료/이자", "연회비", "현금서비스", "신차구매", "의약품전용몰"
    ]
    
    base_benefits = [
        ("all", "언제나할인", "국내외 가맹점 1.2% 청구할인", 0.012),
        ("shopping", "쇼핑", "쇼핑 1.2% 청구할인", 0.012),
        ("cafe", "카페/베이커리", "카페/베이커리 1.2% 청구할인", 0.012),
        ("dining", "외식", "외식업종 1.2% 청구할인", 0.012),
        ("beauty", "뷰티", "뷰티업종 1.2% 청구할인", 0.012),
        ("gas", "주유", "주유 1.2% 청구할인", 0.012),
        ("culture", "문화", "문화업종 1.2% 청구할인", 0.012),
        ("telecom", "통신", "통신 1.2% 청구할인", 0.012),
        ("childcare", "육아", "육아업종 1.2% 청구할인", 0.012),
        ("education", "교육", "교육업종 1.2% 청구할인", 0.012),
        ("movie", "영화", "영화 1.2% 청구할인", 0.012),
        ("medical", "의료", "의료업종 1.2% 청구할인", 0.012),
        ("mart", "대형마트", "대형마트 1.2% 청구할인", 0.012),
        ("cvs", "편의점", "편의점 1.2% 청구할인", 0.012),
        ("transport", "대중교통", "대중교통 1.2% 청구할인", 0.012),
        ("rental", "렌탈", "렌탈업종 1.2% 청구할인", 0.012),
    ]
    
    for category, title, desc, rate in base_benefits:
        benefit_id = f"kb_mr_life_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="kb_mr_life",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="discount",
                rate=rate,
                previous_month_min_spending=500000,
                monthly_usage_limit=3000000,
                monthly_discount_limit=36000,
                quarterly_bonus_enabled=True,
                quarterly_bonus_condition={"monthly_min": 100000, "months": 3},
                quarterly_bonus_amount=15000,
                excluded_merchants=excluded_merchants_common,
                detail_description=f"전월 가맹점 이용실적 50만원 이상 시 할인. 월 이용금액 최대 300만원까지 할인(월 할인한도 최대 36,000원). 분기별 이용실적에 따라 최대 15,000원 청구할인."
            )
            db.add(benefit)


# ===== 신한 Deep Dream 혜택 =====
def _create_shinhan_deep_dream_benefits(db: Session):
    benefits = [
        ("all", "기본할인", "전 가맹점 0.8% 청구할인", 0.008, 2000000, 16000),
        ("cafe", "카페", "카페 5% 청구할인", 0.05, 500000, 25000),
        ("dining", "외식", "외식 5% 청구할인", 0.05, 500000, 25000),
        ("transport", "대중교통", "대중교통 5% 청구할인", 0.05, 300000, 15000),
        ("movie", "영화", "영화 20% 청구할인", 0.20, 100000, 20000),
    ]
    
    for category, title, desc, rate, usage_limit, discount_limit in benefits:
        benefit_id = f"shinhan_deep_dream_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="shinhan_deep_dream",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="discount",
                rate=rate,
                previous_month_min_spending=300000,
                monthly_usage_limit=usage_limit,
                monthly_discount_limit=discount_limit,
                detail_description=f"전월 30만원 이상 사용 시 혜택 제공"
            )
            db.add(benefit)


# ===== 토스뱅크 체크카드 혜택 =====
def _create_toss_check_benefits(db: Session):
    benefit = CardBenefit(
        id="toss_check_all",
        card_id="toss_check",
        category="all",
        title="토스 캐시백",
        short_description="전 가맹점 1% 캐시백",
        benefit_type="cashback",
        rate=0.01,
        previous_month_min_spending=None,
        monthly_usage_limit=None,
        monthly_discount_limit=10000,
        detail_description="월 최대 10,000원까지 캐시백"
    )
    existing = db.query(CardBenefit).filter(CardBenefit.id == "toss_check_all").first()
    if not existing:
        db.add(benefit)


# ===== 카카오뱅크 체크카드 혜택 =====
def _create_kakao_check_benefits(db: Session):
    benefits = [
        ("kakaopay", "카카오페이", "카카오페이 10% 캐시백", 0.10, None, 5000),
        ("all", "기본캐시백", "전 가맹점 0.5% 캐시백", 0.005, None, 5000),
    ]
    
    for category, title, desc, rate, usage_limit, discount_limit in benefits:
        benefit_id = f"kakao_check_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="kakao_check",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="cashback",
                rate=rate,
                monthly_discount_limit=discount_limit,
            )
            db.add(benefit)


# ===== 하나카드 트래블로그 혜택 =====
def _create_hana_travelog_benefits(db: Session):
    benefits = [
        ("travel", "여행", "여행/숙박 10% 청구할인", 0.10, 1000000, 50000),
        ("airline", "항공", "항공권 5% 청구할인", 0.05, 2000000, 50000),
        ("transport", "대중교통", "대중교통 10% 청구할인", 0.10, 300000, 10000),
        ("cafe", "카페", "카페 5% 청구할인", 0.05, 300000, 10000),
    ]
    
    for category, title, desc, rate, usage_limit, discount_limit in benefits:
        benefit_id = f"hana_travelog_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="hana_travelog",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="discount",
                rate=rate,
                previous_month_min_spending=300000,
                monthly_usage_limit=usage_limit,
                monthly_discount_limit=discount_limit,
            )
            db.add(benefit)


# ===== 삼성 taptap O 혜택 =====
def _create_samsung_taptap_benefits(db: Session):
    benefits = [
        ("transport", "대중교통", "대중교통 20% 청구할인", 0.20, 500000, 10000),
        ("gas", "주유", "주유 15% 청구할인", 0.15, 500000, 30000),
        ("cafe", "카페", "카페 10% 청구할인", 0.10, 300000, 10000),
        ("cvs", "편의점", "편의점 10% 청구할인", 0.10, 300000, 10000),
    ]
    
    for category, title, desc, rate, usage_limit, discount_limit in benefits:
        benefit_id = f"samsung_taptap_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="samsung_taptap",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="discount",
                rate=rate,
                previous_month_min_spending=300000,
                monthly_usage_limit=usage_limit,
                monthly_discount_limit=discount_limit,
            )
            db.add(benefit)


# ===== 우리카드 My Way 혜택 =====
def _create_woori_myway_benefits(db: Session):
    benefits = [
        ("all", "기본할인", "전 가맹점 1% 청구할인", 0.01, 2000000, 20000),
        ("shopping", "쇼핑", "쇼핑 3% 청구할인", 0.03, 1000000, 30000),
        ("dining", "외식", "외식 3% 청구할인", 0.03, 500000, 15000),
        ("cafe", "카페", "카페 3% 청구할인", 0.03, 300000, 10000),
    ]
    
    for category, title, desc, rate, usage_limit, discount_limit in benefits:
        benefit_id = f"woori_myway_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="woori_myway",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="discount",
                rate=rate,
                previous_month_min_spending=400000,
                monthly_usage_limit=usage_limit,
                monthly_discount_limit=discount_limit,
            )
            db.add(benefit)


# ===== 현대카드 M 혜택 =====
def _create_hyundai_m_benefits(db: Session):
    benefits = [
        ("culture", "문화", "문화 3% 포인트 적립", 0.03, 1000000, 30000),
        ("movie", "영화", "영화 20% 포인트 적립", 0.20, 200000, 20000),
        ("shopping", "쇼핑", "쇼핑 2% 포인트 적립", 0.02, 2000000, 40000),
        ("dining", "외식", "외식 2% 포인트 적립", 0.02, 1000000, 20000),
    ]
    
    for category, title, desc, rate, usage_limit, discount_limit in benefits:
        benefit_id = f"hyundai_m_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="hyundai_m",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="points",
                rate=rate,
                previous_month_min_spending=500000,
                monthly_usage_limit=usage_limit,
                monthly_discount_limit=discount_limit,
            )
            db.add(benefit)


# ===== NH농협 채움 혜택 =====
def _create_nh_chaeum_benefits(db: Session):
    benefits = [
        ("mart", "대형마트", "대형마트 5% 청구할인", 0.05, 500000, 25000),
        ("cvs", "편의점", "편의점 5% 청구할인", 0.05, 300000, 15000),
        ("gas", "주유", "주유 10% 청구할인", 0.10, 500000, 30000),
        ("transport", "대중교통", "대중교통 10% 청구할인", 0.10, 300000, 10000),
    ]
    
    for category, title, desc, rate, usage_limit, discount_limit in benefits:
        benefit_id = f"nh_chaeum_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="nh_chaeum",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="discount",
                rate=rate,
                previous_month_min_spending=300000,
                monthly_usage_limit=usage_limit,
                monthly_discount_limit=discount_limit,
            )
            db.add(benefit)


# ===== IBK기업 One 혜택 =====
def _create_ibk_one_benefits(db: Session):
    benefits = [
        ("all", "기본할인", "전 가맹점 1.5% 청구할인", 0.015, 2000000, 30000),
        ("cafe", "카페", "카페 추가 2% 청구할인", 0.02, 300000, 6000),
        ("dining", "외식", "외식 추가 2% 청구할인", 0.02, 500000, 10000),
    ]
    
    for category, title, desc, rate, usage_limit, discount_limit in benefits:
        benefit_id = f"ibk_one_{category}"
        existing = db.query(CardBenefit).filter(CardBenefit.id == benefit_id).first()
        if not existing:
            benefit = CardBenefit(
                id=benefit_id,
                card_id="ibk_one",
                category=category,
                title=title,
                short_description=desc,
                benefit_type="discount",
                rate=rate,
                previous_month_min_spending=400000,
                monthly_usage_limit=usage_limit,
                monthly_discount_limit=discount_limit,
            )
            db.add(benefit)


def _add_sample_transactions(db: Session, user_id: str, card_id: str):
    """샘플 거래 내역 추가"""
    categories = [
        ("스타벅스 강남점", "cafe", 5800),
        ("이마트 역삼점", "mart", 45000),
        ("CU편의점", "cvs", 8500),
        ("CGV 강남", "movie", 15000),
        ("교보문고", "culture", 25000),
        ("지하철", "transport", 1350),
        ("버스", "transport", 1400),
        ("GS25", "cvs", 6500),
        ("올리브영", "beauty", 32000),
        ("맥도날드", "dining", 12000),
    ]
    
    # 최근 30일 거래 생성
    now = datetime.now()
    for i in range(30):
        date = now - timedelta(days=i)
        for j in range(2):  # 하루에 2건
            merchant, category, base_amount = categories[(i * 2 + j) % len(categories)]
            amount = base_amount + (i * 100)
            
            tx_id = f"tx_{user_id}_{card_id}_{i}_{j}"
            existing_tx = db.query(Transaction).filter(Transaction.id == tx_id).first()
            if not existing_tx:
                tx = Transaction(
                    id=tx_id,
                    user_id=user_id,
                    card_id=card_id,
                    merchant_name=merchant,
                    merchant_category=category,
                    amount=amount,
                    approved_at=date,
                    is_cancelled=False
                )
                db.add(tx)
                
                # 실적 분류
                perf_class = PerformanceClassification(
                    transaction_id=tx_id,
                    card_id=card_id,
                    is_counted_for_performance=True,
                    is_counted_for_benefit=True,
                    performance_amount=amount
                )
                db.add(perf_class)
    
    db.commit()


if __name__ == "__main__":
    init_sample_data()
