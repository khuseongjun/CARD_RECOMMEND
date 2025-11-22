import requests
from typing import List, Dict, Optional
from enum import Enum

# 카카오 REST API 키
KAKAO_REST_API_KEY = "6b55c81fcd8b6c94a44727edf0fdff6b"

# 카카오 카테고리 그룹 코드
class KakaoCategory(Enum):
    LARGE_MART = "MT1"  # 대형마트
    CONVENIENCE = "CS2"  # 편의점
    RESTAURANT = "FD6"  # 음식점
    CAFE = "CE7"  # 카페
    MOVIE = "CT1"  # 문화시설 (영화관 포함)
    TRANSPORT = "SW8"  # 지하철역

# 카카오 카테고리 → 내부 카테고리 매핑
KAKAO_TO_INTERNAL_CATEGORY = {
    KakaoCategory.RESTAURANT.value: "food",
    KakaoCategory.CAFE.value: "cafe",
    KakaoCategory.MOVIE.value: "movie",
    KakaoCategory.TRANSPORT.value: "transport",
    KakaoCategory.CONVENIENCE.value: "convenience",
    KakaoCategory.LARGE_MART.value: "shopping",
}

def search_nearby_places(
    lat: float,
    lng: float,
    radius: int = 200,
    category: Optional[str] = None,
    size: int = 15
) -> List[Dict]:
    """
    카카오 로컬 API로 주변 장소 검색
    
    Args:
        lat: 위도
        lng: 경도
        radius: 반경 (미터, 0-20000)
        category: 카테고리 코드 (FD6: 음식점, CE7: 카페, CT1: 문화시설 등)
        size: 반환할 결과 개수 (1-15)
    
    Returns:
        장소 정보 리스트
    """
    url = "https://dapi.kakao.com/v2/local/search/category.json"
    
    headers = {
        "Authorization": f"KakaoAK {KAKAO_REST_API_KEY}"
    }
    
    params = {
        "x": str(lng),  # 경도
        "y": str(lat),  # 위도
        "radius": radius,
        "size": min(size, 15),
        "sort": "distance"  # 거리순 정렬
    }
    
    if category:
        params["category_group_code"] = category
    
    try:
        response = requests.get(url, headers=headers, params=params, timeout=5)
        response.raise_for_status()
        
        data = response.json()
        places = []
        
        for doc in data.get("documents", []):
            # 카테고리 매핑
            kakao_category = doc.get("category_group_code", "")
            internal_category = KAKAO_TO_INTERNAL_CATEGORY.get(kakao_category, "etc")
            
            place = {
                "id": doc.get("id"),
                "name": doc.get("place_name"),
                "category": internal_category,
                "kakao_category": kakao_category,
                "address": doc.get("address_name"),
                "road_address": doc.get("road_address_name"),
                "phone": doc.get("phone", ""),
                "lat": float(doc.get("y", 0)),
                "lng": float(doc.get("x", 0)),
                "distance": int(doc.get("distance", 0)),  # 미터 단위
                "place_url": doc.get("place_url", ""),
            }
            places.append(place)
        
        return places
    
    except requests.exceptions.RequestException as e:
        print(f"카카오 로컬 API 호출 실패: {e}")
        return []


def search_multiple_categories(
    lat: float,
    lng: float,
    radius: int = 200,
    categories: Optional[List[str]] = None,
    size_per_category: int = 5
) -> List[Dict]:
    """
    여러 카테고리로 주변 장소 검색
    
    Args:
        lat: 위도
        lng: 경도
        radius: 반경
        categories: 검색할 카테고리 코드 리스트 (None이면 모든 주요 카테고리)
        size_per_category: 카테고리당 반환 개수
    
    Returns:
        모든 카테고리의 장소를 거리순으로 정렬한 리스트
    """
    if categories is None:
        categories = [
            KakaoCategory.CAFE.value,
            KakaoCategory.RESTAURANT.value,
            KakaoCategory.MOVIE.value,
            KakaoCategory.CONVENIENCE.value,
        ]
    
    all_places = []
    
    for category in categories:
        places = search_nearby_places(lat, lng, radius, category, size_per_category)
        all_places.extend(places)
    
    # 거리순 정렬
    all_places.sort(key=lambda x: x["distance"])
    
    return all_places

