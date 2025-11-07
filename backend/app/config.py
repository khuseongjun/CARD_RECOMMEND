"""애플리케이션 설정"""
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """환경 변수 기반 설정"""
    
    # 카카오 API
    kakao_rest_api_key: str = "6b55c81fcd8b6c94a44727edf0fdff6b"
    
    # 데이터베이스
    database_url: str = "sqlite:///./database/card_proto.db"
    
    # 서버
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = True
    
    # 캐시
    cache_ttl_seconds: int = 60
    places_cache_ttl_seconds: int = 30
    
    # 알림 정책
    duplicate_notification_minutes: int = 10
    min_expected_saving: int = 300
    
    # 위치 설정
    default_radius_meters: int = 120
    max_radius_meters: int = 500
    
    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()

