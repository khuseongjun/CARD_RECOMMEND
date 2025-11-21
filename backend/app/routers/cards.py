from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import CardProduct, UserCard
from app.schemas import CardProductResponse, UserCardResponse, UserCardCreate
from typing import List, Optional

router = APIRouter(tags=["cards"])

@router.get("/cards", response_model=List[CardProductResponse])
def search_cards(
    q: Optional[str] = Query(None, description="검색어"),
    db: Session = Depends(get_db)
):
    query = db.query(CardProduct)
    if q:
        query = query.filter(
            (CardProduct.name.contains(q)) |
            (CardProduct.issuer.contains(q))
        )
    return query.all()

@router.get("/cards/{card_id}/details", response_model=CardProductResponse)
def get_card_details(card_id: str, db: Session = Depends(get_db)):
    card = db.query(CardProduct).filter(CardProduct.id == card_id).first()
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    return card

