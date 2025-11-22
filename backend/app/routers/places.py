from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.services.kakao_local_service import search_nearby_places, search_multiple_categories
from app.schemas import PlaceResponse
from typing import List, Optional

router = APIRouter(prefix="/places", tags=["places"])

@router.get("/nearby", response_model=List[PlaceResponse])
def get_nearby_places(
    lat: float = Query(..., description="위도"),
    lng: float = Query(..., description="경도"),
    radius: int = Query(200, ge=0, le=20000, description="반경 (미터)"),
    category: Optional[str] = Query(None, description="카카오 카테고리 코드 (FD6: 음식점, CE7: 카페, CT1: 문화시설 등)"),
    size: int = Query(15, ge=1, le=15, description="반환 개수")
):
    """
    주변 가맹점 검색
    
    카카오 로컬 API를 사용하여 반경 내의 가맹점을 검색합니다.
    """
    try:
        places = search_nearby_places(lat, lng, radius, category, size)
        return places
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"가맹점 검색 실패: {str(e)}")

@router.get("/nearby/all", response_model=List[PlaceResponse])
def get_nearby_places_all(
    lat: float = Query(..., description="위도"),
    lng: float = Query(..., description="경도"),
    radius: int = Query(200, ge=0, le=20000, description="반경 (미터)"),
    size_per_category: int = Query(5, ge=1, le=15, description="카테고리당 반환 개수")
):
    """
     여러 카테고리의 주변 가맹점 검색
    
    카페, 음식점, 문화시설 등 주요 카테고리의 가맹점을 모두 검색하여 거리순으로 반환합니다.
    """
    try:
        places = search_multiple_categories(lat, lng, radius, None, size_per_category)
        return places[:30]  # 최대 30개 반환
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"가맹점 검색 실패: {str(e)}")

