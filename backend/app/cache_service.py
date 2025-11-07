"""간단한 인메모리 캐시 서비스"""
from typing import Optional, Any
from datetime import datetime, timedelta
import json


class SimpleCache:
    """간단한 메모리 캐시"""
    
    def __init__(self):
        self._cache: dict = {}
    
    def get(self, key: str) -> Optional[Any]:
        """캐시에서 값 조회"""
        if key in self._cache:
            data, expiry = self._cache[key]
            if datetime.now() < expiry:
                return data
            else:
                # 만료된 캐시 삭제
                del self._cache[key]
        return None
    
    def set(self, key: str, value: Any, ttl_seconds: int = 60):
        """캐시에 값 저장"""
        expiry = datetime.now() + timedelta(seconds=ttl_seconds)
        self._cache[key] = (value, expiry)
    
    def delete(self, key: str):
        """캐시에서 값 삭제"""
        if key in self._cache:
            del self._cache[key]
    
    def clear(self):
        """캐시 전체 삭제"""
        self._cache.clear()
    
    def generate_places_key(self, lat: float, lng: float, radius: int) -> str:
        """장소 검색 캐시 키 생성"""
        # 소수점 4자리로 반올림하여 키 생성
        lat_rounded = round(lat, 4)
        lng_rounded = round(lng, 4)
        return f"places:{lat_rounded}:{lng_rounded}:{radius}"


# 싱글톤 인스턴스
cache = SimpleCache()

