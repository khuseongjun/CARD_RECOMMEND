"""FastAPI 메인 애플리케이션"""
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import logging

from app.config import settings
from app.database import get_db, init_db, Card, Benefit
from app.schemas import (
    PlacesNearbyRequest,
    PlacesNearbyResponse,
    RecommendRequest,
    RecommendResponseList,
    UserRegister,
    UserLogin,
    TokenResponse,
    UserResponse,
    UserCardRegister,
    CardResponse,
    CardDetailResponse,
)
from app.kakao_service import kakao_service
from app.recommendation_service import get_recommendation_service
from app.auth_service import get_auth_service
from app.cache_service import cache

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# FastAPI 앱 생성
app = FastAPI(
    title="Card Proto API",
    description="카드 혜택 추천 서비스 API",
    version="1.0.0"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 특정 도메인만 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup_event():
    """서버 시작 시 초기화"""
    logger.info("서버 시작 중...")
    init_db()
    logger.info("데이터베이스 초기화 완료")


@app.get("/")
async def root():
    """헬스 체크"""
    return {"status": "ok", "message": "Card Proto API is running"}


# ===== 인증 API =====

@app.post("/api/auth/register", response_model=UserResponse, tags=["Auth"])
async def register(
    user_data: UserRegister,
    db: Session = Depends(get_db)
):
    """회원가입"""
    auth_service = get_auth_service(db)
    return auth_service.register_user(user_data)


@app.post("/api/auth/login", response_model=TokenResponse, tags=["Auth"])
async def login(
    login_data: UserLogin,
    db: Session = Depends(get_db)
):
    """로그인"""
    auth_service = get_auth_service(db)
    return auth_service.login_user(login_data)


@app.get("/api/auth/me/{user_id}", response_model=UserResponse, tags=["Auth"])
async def get_current_user(
    user_id: int,
    db: Session = Depends(get_db)
):
    """현재 사용자 정보 조회"""
    auth_service = get_auth_service(db)
    return auth_service.get_user_by_id(user_id)


# ===== 카드 API =====

@app.get("/api/cards", response_model=List[CardResponse], tags=["Cards"])
async def list_cards(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """카드 목록 조회"""
    cards = db.query(Card).offset(skip).limit(limit).all()
    return cards


@app.get("/api/cards/{card_id}", response_model=CardDetailResponse, tags=["Cards"])
async def get_card_detail(
    card_id: int,
    db: Session = Depends(get_db)
):
    """카드 상세 정보 조회"""
    card = db.query(Card).filter(Card.card_id == card_id).first()
    
    if not card:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="카드를 찾을 수 없습니다"
        )
    
    return card


@app.post("/api/users/{user_id}/cards", tags=["Cards"])
async def register_user_card(
    user_id: int,
    card_data: UserCardRegister,
    db: Session = Depends(get_db)
):
    """사용자 카드 등록"""
    auth_service = get_auth_service(db)
    success = auth_service.register_user_card(user_id, card_data.card_id)
    return {"success": success, "message": "카드가 등록되었습니다"}


@app.get("/api/users/{user_id}/cards", response_model=List[CardResponse], tags=["Cards"])
async def get_user_cards(
    user_id: int,
    db: Session = Depends(get_db)
):
    """사용자 등록 카드 목록 조회"""
    auth_service = get_auth_service(db)
    card_ids = auth_service.get_user_cards(user_id)
    
    cards = db.query(Card).filter(Card.card_id.in_(card_ids)).all()
    return cards


@app.delete("/api/users/{user_id}/cards/{card_id}", tags=["Cards"])
async def delete_user_card(
    user_id: int,
    card_id: int,
    db: Session = Depends(get_db)
):
    """사용자 카드 삭제"""
    auth_service = get_auth_service(db)
    success = auth_service.delete_user_card(user_id, card_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="카드를 찾을 수 없거나 삭제에 실패했습니다"
        )
    
    return {"success": True, "message": "카드가 삭제되었습니다"}


# ===== 장소 검색 API =====

@app.post("/api/places/nearby", response_model=PlacesNearbyResponse, tags=["Places"])
async def get_nearby_places(
    request: PlacesNearbyRequest
):
    """주변 장소 검색 (카카오 Local API)"""
    
    # 캐시 확인
    cache_key = cache.generate_places_key(request.lat, request.lng, request.radius)
    cached_result = cache.get(cache_key)
    
    if cached_result:
        logger.info(f"캐시 히트: {cache_key}")
        return cached_result
    
    # API 호출
    try:
        places = await kakao_service.search_nearby_places(
            lat=request.lat,
            lng=request.lng,
            radius=request.radius
        )
        
        result = PlacesNearbyResponse(
            places=places,
            total_count=len(places)
        )
        
        # 캐시 저장
        cache.set(cache_key, result, ttl_seconds=settings.places_cache_ttl_seconds)
        
        return result
    
    except Exception as e:
        logger.error(f"장소 검색 실패: {e}")
        
        # 최근 성공 결과 재사용 시도
        if cached_result:
            logger.info("이전 캐시 결과 재사용")
            return cached_result
        
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="장소 검색 중 오류가 발생했습니다"
        )


# ===== 추천 API =====

@app.post("/api/recommend", response_model=RecommendResponseList, tags=["Recommend"])
async def recommend_cards(
    request: RecommendRequest,
    db: Session = Depends(get_db)
):
    """카드 혜택 추천"""
    
    recommendation_service = get_recommendation_service(db)
    
    try:
        recommendations = recommendation_service.recommend_cards(request)
        
        return RecommendResponseList(
            recommendations=recommendations,
            merchant_name=request.merchant_name,
            merchant_category=request.merchant_category
        )
    
    except Exception as e:
        logger.error(f"추천 실패: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="추천 처리 중 오류가 발생했습니다"
        )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug
    )

