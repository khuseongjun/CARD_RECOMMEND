from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import CardProduct, UserCard
from app.schemas import UserCardResponse, UserCardCreate
from typing import List

router = APIRouter(prefix="/users/{user_id}/cards", tags=["user_cards"])

@router.get("", response_model=List[UserCardResponse])
def get_user_cards(user_id: str, db: Session = Depends(get_db)):
    user_cards = db.query(UserCard).filter(UserCard.user_id == user_id).all()
    result = []
    for uc in user_cards:
        card = db.query(CardProduct).filter(CardProduct.id == uc.card_id).first()
        uc_dict = {
            "id": uc.id,
            "user_id": uc.user_id,
            "card_id": uc.card_id,
            "nickname": uc.nickname,
            "registered_at": uc.registered_at,
            "card": card
        }
        result.append(UserCardResponse(**uc_dict))
    return result

@router.post("", response_model=UserCardResponse)
def add_user_card(user_id: str, card_data: UserCardCreate, db: Session = Depends(get_db)):
    # 카드 존재 확인
    card = db.query(CardProduct).filter(CardProduct.id == card_data.card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    
    # 이미 등록된 카드인지 확인
    existing = db.query(UserCard).filter(
        UserCard.user_id == user_id,
        UserCard.card_id == card_data.card_id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Card already registered")
    
    user_card = UserCard(
        user_id=user_id,
        card_id=card_data.card_id,
        nickname=card_data.nickname
    )
    db.add(user_card)
    db.commit()
    db.refresh(user_card)
    
    return UserCardResponse(
        id=user_card.id,
        user_id=user_card.user_id,
        card_id=user_card.card_id,
        nickname=user_card.nickname,
        registered_at=user_card.registered_at,
        card=card
    )

@router.delete("/{card_id}")
def delete_user_card(user_id: str, card_id: str, db: Session = Depends(get_db)):
    user_card = db.query(UserCard).filter(
        UserCard.user_id == user_id,
        UserCard.card_id == card_id
    ).first()
    if not user_card:
        raise HTTPException(status_code=404, detail="User card not found")
    
    db.delete(user_card)
    db.commit()
    return {"message": "Card deleted successfully"}

