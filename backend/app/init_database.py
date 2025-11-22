import os
import json
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.database import SessionLocal, engine, Base
from app.models import (
    User, CardProduct, CardPerformanceTier, CardBenefit,
    Badge, UserCard, Transaction, PerformanceClassification, UserBadge
)

def init_database():
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
        
        # ===== JSON 파일 경로 정의 =====
        BASE_DIR = os.path.dirname(os.path.abspath(__file__))
        dataset_dir = os.path.join(BASE_DIR, "dataset")

        json_files = {
            "cards": "cards_data.json",
            "benefits": "cards_benefitsdata.json",
            "performance_tiers": "cards_performance_tiers.json",
            "badges": "badges_data.json",
            "user_cards": "user_cards.json",
            "sample_transactions": "sample_transactions.json"
        }
        
        # ===== 카드 데이터 삽입 =====
        cards_path = os.path.join(dataset_dir, json_files["cards"])
        with open(cards_path, "r", encoding="utf-8") as f:
            cards_data = json.load(f)
        
        for card_data in cards_data:
            existing_card = db.query(CardProduct).filter(CardProduct.id == card_data["id"]).first()
            if not existing_card:
                db.add(CardProduct(**card_data))
            else:
                # 모든 필드 업데이트 (image_url 포함)
                for key, value in card_data.items():
                    if hasattr(existing_card, key):
                        setattr(existing_card, key, value)
        db.commit()
        
        # ===== 카드 혜택 삽입 =====
        benefits_path = os.path.join(dataset_dir, json_files["benefits"])
        with open(benefits_path, "r", encoding="utf-8") as f:
            benefits_data = json.load(f)
        
        for benefit_data in benefits_data:
            if not db.query(CardBenefit).filter(CardBenefit.id == benefit_data["id"]).first():
                db.add(CardBenefit(**benefit_data))
        db.commit()
        
        # ===== 카드 실적 구간 삽입 =====
        tiers_path = os.path.join(dataset_dir, json_files["performance_tiers"])
        with open(tiers_path, "r", encoding="utf-8") as f:
            tiers_data = json.load(f)
        
        for tier_data in tiers_data:
            if not db.query(CardPerformanceTier).filter(
                CardPerformanceTier.card_id == tier_data["card_id"],
                CardPerformanceTier.tier_code == tier_data["tier_code"]
            ).first():
                db.add(CardPerformanceTier(**tier_data))
        db.commit()
        
        # ===== 뱃지 데이터 삽입 =====
        badges_path = os.path.join(dataset_dir, json_files["badges"])
        with open(badges_path, "r", encoding="utf-8") as f:
            badges_data = json.load(f)
        
        for badge_data in badges_data:
            if not db.query(Badge).filter(Badge.id == badge_data["id"]).first():
                db.add(Badge(**badge_data))
        db.commit()
        
        # ===== 사용자 카드 등록 =====
        user_cards_path = os.path.join(dataset_dir, json_files["user_cards"])
        with open(user_cards_path, "r", encoding="utf-8") as f:
            user_cards_data = json.load(f)
        
        for uc in user_cards_data:
            if not db.query(UserCard).filter(UserCard.user_id == uc["user_id"], UserCard.card_id == uc["card_id"]).first():
                db.add(UserCard(**uc))
        db.commit()
        
        # ===== 샘플 거래 내역 삽입 =====
        tx_path = os.path.join(dataset_dir, json_files["sample_transactions"])
        with open(tx_path, "r", encoding="utf-8") as f:
            transactions_data = json.load(f)
        
        for tx in transactions_data:
            if not db.query(Transaction).filter(Transaction.id == tx["id"]).first():
                tx["approved_at"] = datetime.fromisoformat(tx["approved_at"])
                db.add(Transaction(**tx))

                # 실적 분류 추가
                db.add(PerformanceClassification(
                    transaction_id=tx["id"],
                    card_id=tx["card_id"],
                    is_counted_for_performance=True,
                    is_counted_for_benefit=True,
                    performance_amount=tx["amount"]
                ))
        db.commit()
        
        # ===== 사용자 뱃지 획득 예시 =====
        first_card_badge = db.query(UserBadge).filter(
            UserBadge.user_id == "user_123",
            UserBadge.badge_id == "first_card"
        ).first()
        if not first_card_badge:
            db.add(UserBadge(
                user_id="user_123",
                badge_id="first_card",
                earned_at=datetime.now()
            ))
        db.commit()
        
        print("✅ 성공!")
    
    except Exception as e:
        db.rollback()
        print(f"❌ 에러 발생: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    init_database()
