"""샘플 데이터 초기화 스크립트"""
import sys
import os

# 상위 디렉토리를 path에 추가
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import SessionLocal, Card, Benefit, BenefitScope, TimeWindow, SpendTier, init_db
from datetime import date


def create_sample_data():
    """샘플 데이터 생성"""
    
    # 데이터베이스 초기화
    init_db()
    
    db = SessionLocal()
    
    try:
        # 기존 데이터 확인
        existing_cards = db.query(Card).count()
        if existing_cards > 0:
            print(f"이미 {existing_cards}개의 카드가 존재합니다. 삭제 후 다시 실행하세요.")
            return
        
        # D4 카드 생성
        d4_card = Card(
            card_id=101,
            issuer="신한",
            name="D4 카드의 정석",
            annual_fee_text="국내전용 12,000원 / MASTER 12,000원",
            min_spend_text="전월실적 최소 30만원",
            image_url="https://example.com/cards/d4.png"
        )
        db.add(d4_card)
        db.flush()
        
        # 커피 혜택 (55%)
        coffee_benefit = Benefit(
            benefit_id=2001,
            card_id=101,
            title="커피 55%",
            short_desc="스타벅스, 투썸플레이스, 커피빈, 폴바셋에서 55% 청구할인",
            benefit_type="discount",
            rate_pct=55.0,
            per_txn_amount_cap=10000,
            per_txn_discount_cap=1000,
            per_day=1,
            per_month=5,
            group_key=None,
            valid_from=date(2025, 1, 1),
            valid_to=None,
            priority=1
        )
        db.add(coffee_benefit)
        db.flush()
        
        # 커피 스코프
        coffee_scope = BenefitScope(
            benefit_id=2001,
            scope_type="CATEGORY",
            scope_value="COFFEE",
            include=True
        )
        db.add(coffee_scope)
        
        # 대중교통 혜택 (33%)
        transport_benefit = Benefit(
            benefit_id=2002,
            card_id=101,
            title="대중교통 33%",
            short_desc="버스, 지하철, 택시에서 33% 청구할인",
            benefit_type="discount",
            rate_pct=33.0,
            per_txn_amount_cap=10000,
            per_txn_discount_cap=1000,
            per_day=2,
            per_month=10,
            group_key=None,
            valid_from=date(2025, 1, 1),
            valid_to=None,
            priority=2
        )
        db.add(transport_benefit)
        db.flush()
        
        # 편의점 혜택 (11%)
        convenience_benefit = Benefit(
            benefit_id=2003,
            card_id=101,
            title="편의점 11%",
            short_desc="편의점에서 11% 청구할인",
            benefit_type="discount",
            rate_pct=11.0,
            per_txn_amount_cap=10000,
            per_txn_discount_cap=1000,
            per_day=1,
            per_month=10,
            group_key=None,
            valid_from=date(2025, 1, 1),
            valid_to=None,
            priority=3
        )
        db.add(convenience_benefit)
        db.flush()
        
        # 편의점 스코프
        conv_scope = BenefitScope(
            benefit_id=2003,
            scope_type="CATEGORY",
            scope_value="CONVENIENCE_STORE",
            include=True
        )
        db.add(conv_scope)
        
        # 영화 혜택 (5,500원 할인)
        movie_benefit = Benefit(
            benefit_id=2004,
            card_id=101,
            title="영화 5,500원 할인",
            short_desc="영화 5,500원 청구할인",
            benefit_type="discount",
            flat_amount=5500,
            per_day=1,
            per_month=5,
            group_key=None,
            valid_from=date(2025, 1, 1),
            valid_to=None,
            priority=4
        )
        db.add(movie_benefit)
        
        # 전월실적 구간 (샘플)
        spend_tiers = [
            SpendTier(card_id=101, benefit_group="ALLDAY", min_spend=300000, max_spend=500000, monthly_total_cap=10000),
            SpendTier(card_id=101, benefit_group="ALLDAY", min_spend=500000, max_spend=1000000, monthly_total_cap=20000),
            SpendTier(card_id=101, benefit_group="ALLDAY", min_spend=1000000, max_spend=None, monthly_total_cap=30000),
        ]
        
        for tier in spend_tiers:
            db.add(tier)
        
        # Mr.Life 카드 생성 (추가 카드)
        mrlife_card = Card(
            card_id=102,
            issuer="신한",
            name="Mr.Life",
            annual_fee_text="국내전용 15,000원 / 해외 18,000원",
            min_spend_text="전월실적 30만원~",
            image_url="https://example.com/cards/mrlife.png"
        )
        db.add(mrlife_card)
        db.flush()
        
        # Mr.Life 커피 혜택 (10%)
        mrlife_coffee = Benefit(
            benefit_id=2101,
            card_id=102,
            title="커피 10%",
            short_desc="커피전문점 10% 할인",
            benefit_type="discount",
            rate_pct=10.0,
            per_txn_amount_cap=10000,
            per_txn_discount_cap=1000,
            per_day=1,
            per_month=10,
            group_key=None,
            valid_from=date(2025, 1, 1),
            valid_to=None,
            priority=1
        )
        db.add(mrlife_coffee)
        db.flush()
        
        # Mr.Life 커피 스코프
        mrlife_coffee_scope = BenefitScope(
            benefit_id=2101,
            scope_type="CATEGORY",
            scope_value="COFFEE",
            include=True
        )
        db.add(mrlife_coffee_scope)
        
        # 야간 시간대 (21:00 ~ 09:00)
        night_time = TimeWindow(
            benefit_id=2101,
            start_time="21:00",
            end_time="09:00",
            days_of_week="1|2|3|4|5|6|7"
        )
        db.add(night_time)
        
        db.commit()
        
        print("✅ 샘플 데이터 생성 완료!")
        print(f"  - D4 카드의 정석 (ID: 101) - 4개 혜택")
        print(f"  - Mr.Life 카드 (ID: 102) - 1개 혜택")
        
    except Exception as e:
        db.rollback()
        print(f"❌ 에러 발생: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    create_sample_data()

