"""카카오 Local API 연동 서비스"""
import httpx
from typing import List, Dict, Optional
from app.config import settings
from app.schemas import PlaceResponse
import logging

logger = logging.getLogger(__name__)

# 카카오 카테고리 코드 매핑
CATEGORY_CODE_MAP = {
    "MART": "MT1",  # 대형마트
    "CONVENIENCE_STORE": "CS2",  # 편의점
    "GAS_STATION": "OL7",  # 주유소
    "SUBWAY": "SW8",  # 지하철역
    "BANK": "BK9",  # 은행
    "CULTURE": "CT1",  # 문화시설
    "TOURISM": "AT4",  # 관광명소
    "ACCOMMODATION": "AD5",  # 숙박
    "RESTAURANT": "FD6",  # 음식점
    "CAFE": "CE7",  # 카페
    "COFFEE": "CE7",  # 커피 (카페와 동일)
    "HOSPITAL": "HP8",  # 병원
    "PHARMACY": "PM9",  # 약국
}

# 역매핑 (카카오 코드 -> 내부 카테고리)
KAKAO_TO_INTERNAL = {v: k for k, v in CATEGORY_CODE_MAP.items()}


class KakaoLocalService:
    """카카오 Local API 서비스"""
    
    BASE_URL = "https://dapi.kakao.com/v2/local"
    
    def __init__(self):
        self.api_key = settings.kakao_rest_api_key
        self.headers = {
            "Authorization": f"KakaoAK {self.api_key}"
        }
    
    async def search_places_by_category(
        self,
        lat: float,
        lng: float,
        category_code: str,
        radius: int = 120,
        page: int = 1,
        size: int = 15
    ) -> Dict:
        """카테고리별 장소 검색"""
        url = f"{self.BASE_URL}/search/category.json"
        
        params = {
            "category_group_code": category_code,
            "x": lng,  # 경도
            "y": lat,  # 위도
            "radius": min(radius, 20000),  # 최대 20km
            "sort": "distance",  # 거리순 정렬
            "page": page,
            "size": size
        }
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(url, headers=self.headers, params=params, timeout=10.0)
                response.raise_for_status()
                return response.json()
        except httpx.HTTPError as e:
            logger.error(f"카카오 API 요청 실패: {e}")
            return {"meta": {"total_count": 0, "pageable_count": 0, "is_end": True}, "documents": []}
    
    async def search_nearby_places(
        self,
        lat: float,
        lng: float,
        radius: int = 120,
        categories: Optional[List[str]] = None
    ) -> List[PlaceResponse]:
        """주변 장소 검색 (여러 카테고리)"""
        
        # 카테고리가 지정되지 않으면 주요 카테고리 사용
        if not categories:
            categories = ["CONVENIENCE_STORE", "CAFE", "RESTAURANT", "MART", "GAS_STATION"]
        
        all_places = []
        
        for category in categories:
            kakao_code = CATEGORY_CODE_MAP.get(category)
            if not kakao_code:
                logger.warning(f"알 수 없는 카테고리: {category}")
                continue
            
            result = await self.search_places_by_category(lat, lng, kakao_code, radius)
            
            for doc in result.get("documents", []):
                place = PlaceResponse(
                    id=doc.get("id", ""),
                    place_name=doc.get("place_name", ""),
                    category_name=doc.get("category_name", ""),
                    category_group_code=doc.get("category_group_code", ""),
                    category_group_name=doc.get("category_group_name", ""),
                    phone=doc.get("phone", ""),
                    address_name=doc.get("address_name", ""),
                    road_address_name=doc.get("road_address_name", ""),
                    x=doc.get("x", ""),
                    y=doc.get("y", ""),
                    distance=doc.get("distance", "")
                )
                all_places.append(place)
        
        # 거리순 정렬
        all_places.sort(key=lambda p: int(p.distance) if p.distance and p.distance.isdigit() else 999999)
        
        return all_places
    
    def map_kakao_category_to_internal(self, kakao_category_group_code: str) -> str:
        """카카오 카테고리 코드를 내부 카테고리로 변환"""
        return KAKAO_TO_INTERNAL.get(kakao_category_group_code, "UNKNOWN")
    
    def extract_category_from_name(self, category_name: str) -> str:
        """카테고리명에서 주요 카테고리 추출"""
        # 예: "음식점 > 카페,디저트 > 커피전문점" -> "COFFEE"
        if "커피" in category_name or "카페" in category_name:
            return "COFFEE"
        elif "편의점" in category_name:
            return "CONVENIENCE_STORE"
        elif "음식점" in category_name:
            return "RESTAURANT"
        elif "마트" in category_name:
            return "MART"
        elif "주유" in category_name:
            return "GAS_STATION"
        elif "병원" in category_name:
            return "HOSPITAL"
        elif "약국" in category_name:
            return "PHARMACY"
        else:
            return "UNKNOWN"


# 싱글톤 인스턴스
kakao_service = KakaoLocalService()

