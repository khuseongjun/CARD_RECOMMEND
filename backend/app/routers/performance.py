from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.performance_service import get_performance_summary
from app.schemas import PerformanceResponse

router = APIRouter(prefix="/users/{user_id}/cards/{card_id}/performance", tags=["performance"])

@router.get("", response_model=PerformanceResponse)
def get_card_performance(
    user_id: str,
    card_id: str,
    month: str = Query(..., description="YYYY-MM 형식"),
    db: Session = Depends(get_db)
):
    year, month_num = map(int, month.split("-"))
    return get_performance_summary(user_id, card_id, year, month_num, db)

