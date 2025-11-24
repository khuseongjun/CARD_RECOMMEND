from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional
import uuid
import os
import random
import time

# Project imports
from app.database import SessionLocal
from app.models import UserCard, CardProduct, CardBenefit, Transaction
from app.services.benefit_rule_engine import classify_performance, calculate_benefit
from app.schemas import CurrentRecommendationResponse

# -----------------------------
# QR/NFC 시뮬레이션용 데이터
# -----------------------------
SIMULATED_QR_DATA = [
    "merchant_name=스타벅스 강남점&merchant_category=cafe&amount=5800",
    "merchant_name=CU편의점&merchant_category=cvs&amount=8500",
    "merchant_name=CGV 강남&merchant_category=movie&amount=15000"
]

def read_qr_code(file_path: str) -> str:
    """시뮬레이션용 QR 읽기"""
    data = random.choice(SIMULATED_QR_DATA)
    return data

def read_nfc_tag() -> str:
    """시뮬레이션용 NFC 읽기"""
    data = random.choice(SIMULATED_QR_DATA)
    return data

# -----------------------------
# 최적 카드 추천
# -----------------------------
def select_best_card_for_transaction(transaction: Transaction, db: Session) -> Optional[CurrentRecommendationResponse]:
    user_cards = db.query(UserCard).filter(UserCard.user_id == transaction.user_id).all()
    if not user_cards:
        return None

    best_card = None
    best_benefit_amount = -1
    best_benefit_desc = ""
    current_month_spending = 0 

    for user_card in user_cards:
        card = db.query(CardProduct).filter(CardProduct.id == user_card.card_id).first()
        if not card:
            continue
        card_benefits = db.query(CardBenefit).filter(CardBenefit.card_id == card.id).all()

        original_card_id = transaction.card_id
        transaction.card_id = card.id
        aggregations = calculate_benefit(transaction, card_benefits, current_month_spending, db)
        transaction.card_id = original_card_id

        total_benefit = sum(a.benefit_amount for a in aggregations)
        if total_benefit > best_benefit_amount:
            best_benefit_amount = total_benefit
            best_card = card
            best_benefit_desc = aggregations[0].benefit_type if aggregations else "혜택 없음"

    if not best_card and user_cards:
        card = db.query(CardProduct).filter(CardProduct.id == user_cards[0].card_id).first()
        return CurrentRecommendationResponse(
            card_id=card.id,
            card_name=card.name,
            merchant_name=transaction.merchant_name,
            benefit_description="기본 결제",
            expected_benefit=0
        )

    if best_card:
        return CurrentRecommendationResponse(
            card_id=best_card.id,
            card_name=best_card.name,
            merchant_name=transaction.merchant_name,
            benefit_description=best_benefit_desc,
            expected_benefit=best_benefit_amount
        )
    return None

# -----------------------------
# 거래 생성
# -----------------------------
def create_transaction_from_data(user_id: str, data: str) -> Transaction:
    """QR/NFC 데이터 문자열을 Transaction 객체로 변환"""
    params = dict(x.split("=") for x in data.split("&"))
    return Transaction(
        id=str(uuid.uuid4()),
        user_id=user_id,
        merchant_name=params.get("merchant_name", "Unknown"),
        merchant_category=params.get("merchant_category", "others"),
        amount=int(params.get("amount", 0)),
        approved_at=datetime.now(),
        is_cancelled=False,
        card_id="",
        is_offline_card=True
    )

# -----------------------------
# 결제 (시뮬레이션)
# -----------------------------
def make_payment(transaction: Transaction, card: CardProduct, simulate: bool = True) -> bool:
    if simulate:
        print(f"[시뮬레이션] {transaction.amount}원 {transaction.merchant_name} 결제 완료 (카드: {card.name})")
        return True
    return False  # 실제 PG 연동 시 구현

# -----------------------------
# 통합 결제 플로우
# -----------------------------
def process_payment(user_id: str, qr_file: Optional[str] = None, use_nfc: bool = False, simulate: bool = True):
    with SessionLocal() as db:
        try:
            # 1. 데이터 읽기
            data = ""
            if use_nfc:
                data = read_nfc_tag()
                if not data:
                    return {"status": "error", "message": "NFC 데이터 읽기 실패"}
            elif qr_file:
                data = read_qr_code(qr_file)
                if not data:
                    return {"status": "error", "message": "QR 데이터 읽기 실패"}
            else:
                return {"status": "error", "message": "QR 또는 NFC 데이터 필요"}

            # 2. 거래 객체 생성
            tx = create_transaction_from_data(user_id, data)

            # 3. 최적 카드 추천
            recommendation = select_best_card_for_transaction(tx, db)
            if not recommendation:
                return {"status": "error", "message": "추천 카드 없음"}

            tx.card_id = recommendation.card_id

            # 4. 실적 분류
            classification = classify_performance(tx, db)
            
            # 5. 결제 진행
            time.sleep(3) 
            card = db.query(CardProduct).filter(CardProduct.id == recommendation.card_id).first()
            payment_success = make_payment(tx, card, simulate=simulate)
            
            if payment_success:
                db.add(tx)
                db.commit()
                return {
                    "status": "success",
                    "transaction": {
                        "merchant_name": tx.merchant_name,
                        "merchant_category": tx.merchant_category,
                        "amount": tx.amount,
                        "date": tx.approved_at
                    },
                    "recommendation": {
                        "card_name": recommendation.card_name,
                        "expected_benefit": recommendation.expected_benefit,
                        "benefit_description": recommendation.benefit_description
                    },
                    "classification": classification.reason
                }
            else:
                return {"status": "error", "message": "결제 실패"}

        except Exception as e:
            db.rollback()
            return {"status": "error", "message": f"결제 처리 중 오류: {str(e)}"}

# -----------------------------
# 테스트 실행
# -----------------------------
if __name__ == "__main__":
    TEST_USER_ID = "user_123"

    print("\n=== QR 결제 테스트 (시뮬레이션) ===")
    process_payment(user_id=TEST_USER_ID, qr_file="app/services/test_qr.png", simulate=True)
