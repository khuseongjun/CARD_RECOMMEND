"""Pydantic 스키마 정의"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import date


# 카드 스키마
class CardBase(BaseModel):
    issuer: str
    name: str
    annual_fee_text: Optional[str] = None
    min_spend_text: Optional[str] = None
    image_url: Optional[str] = None


class CardCreate(CardBase):
    pass


class CardResponse(CardBase):
    card_id: int
    
    class Config:
        from_attributes = True


# 혜택 스키마
class BenefitScopeResponse(BaseModel):
    scope_type: str
    scope_value: str
    include: bool
    
    class Config:
        from_attributes = True


class TimeWindowResponse(BaseModel):
    start_time: str
    end_time: str
    days_of_week: Optional[str] = None
    
    class Config:
        from_attributes = True


class BenefitResponse(BaseModel):
    benefit_id: int
    card_id: int
    title: str
    short_desc: Optional[str] = None
    benefit_type: Optional[str] = None
    rate_pct: Optional[float] = None
    flat_amount: Optional[int] = None
    per_txn_amount_cap: Optional[int] = None
    per_txn_discount_cap: Optional[int] = None
    per_day: Optional[int] = None
    per_month: Optional[int] = None
    group_key: Optional[str] = None
    priority: int
    scopes: List[BenefitScopeResponse] = []
    time_windows: List[TimeWindowResponse] = []
    
    class Config:
        from_attributes = True


class CardDetailResponse(CardResponse):
    benefits: List[BenefitResponse] = []


# 장소 검색 스키마
class PlaceResponse(BaseModel):
    place_id: str = Field(alias="id")
    place_name: str
    category_name: str
    category_group_code: Optional[str] = None
    category_group_name: Optional[str] = None
    phone: Optional[str] = None
    address_name: str
    road_address_name: Optional[str] = None
    x: str  # longitude
    y: str  # latitude
    distance: Optional[str] = None
    
    class Config:
        populate_by_name = True


class PlacesNearbyRequest(BaseModel):
    lat: float = Field(..., ge=-90, le=90)
    lng: float = Field(..., ge=-180, le=180)
    radius: int = Field(default=120, ge=10, le=500)


class PlacesNearbyResponse(BaseModel):
    places: List[PlaceResponse]
    total_count: int


# 추천 스키마
class RecommendRequest(BaseModel):
    user_id: int
    merchant_category: str
    merchant_name: Optional[str] = None
    amount: int = Field(default=10000, ge=1000)
    timestamp: str
    lat: Optional[float] = None
    lng: Optional[float] = None


class RecommendationResponse(BaseModel):
    card_id: int
    card_name: str
    card_issuer: str
    card_image_url: Optional[str] = None
    benefit_title: str
    benefit_desc: str
    expected_saving: int
    discount_rate: Optional[float] = None
    conditions: List[str] = []
    priority: int


class RecommendResponseList(BaseModel):
    recommendations: List[RecommendationResponse]
    merchant_name: Optional[str] = None
    merchant_category: str


# 사용자 스키마
class UserRegister(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: EmailStr
    nickname: str = Field(..., min_length=2, max_length=50)
    password: str = Field(..., min_length=6)


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    user_id: int
    username: str
    email: str
    nickname: str
    created_at: Optional[str] = None
    
    class Config:
        from_attributes = True


class UserCardRegister(BaseModel):
    card_id: int


class UserCardResponse(BaseModel):
    user_card_id: int
    user_id: int
    card_id: int
    registered_at: Optional[str] = None
    
    class Config:
        from_attributes = True


# 인증 토큰 (간단한 구현)
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse

