from pydantic import BaseModel, EmailStr
from typing import Optional, List, Dict, Any
from datetime import datetime

# User Schemas
class UserBase(BaseModel):
    name: str
    email: EmailStr
    preferred_benefit_type: Optional[str] = None
    representative_badge_id: Optional[str] = None

class UserCreate(UserBase):
    pass

class UserUpdate(BaseModel):
    name: Optional[str] = None
    preferred_benefit_type: Optional[str] = None
    representative_badge_id: Optional[str] = None

class UserResponse(UserBase):
    id: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

# Card Product Schemas
class CardProductBase(BaseModel):
    name: str
    issuer: str
    card_type: List[str]
    benefit_types: List[str]
    annual_fee_domestic: int
    annual_fee_international: int
    min_monthly_spending: int
    image_url: Optional[str] = None

class CardProductCreate(CardProductBase):
    id: str

class CardProductResponse(CardProductBase):
    id: str
    
    class Config:
        from_attributes = True

# Card Performance Tier Schemas
class TierInfo(BaseModel):
    code: str
    label: str
    min_amount: int
    max_amount: Optional[int] = None

class CardPerformanceTierResponse(BaseModel):
    card_id: str
    tiers: List[TierInfo]

# Card Benefit Schemas
class MonthlyLimitBySpending(BaseModel):
    spending_min: int
    spending_max: Optional[int] = None
    limit: int

class TimeCondition(BaseModel):
    start: str
    end: str

class CardBenefitBase(BaseModel):
    category: str
    title: str
    short_description: Optional[str] = None
    benefit_type: str
    rate: Optional[float] = None
    time_condition: Optional[TimeCondition] = None
    monthly_limit_by_spending: Optional[List[MonthlyLimitBySpending]] = None
    raw_description: Optional[str] = None

class CardBenefitCreate(CardBenefitBase):
    id: str
    card_id: str

class CardBenefitResponse(CardBenefitBase):
    id: str
    card_id: str
    
    class Config:
        from_attributes = True

# User Card Schemas
class UserCardCreate(BaseModel):
    card_id: str
    nickname: Optional[str] = None

class UserCardResponse(BaseModel):
    id: int
    user_id: str
    card_id: str
    nickname: Optional[str] = None
    registered_at: datetime
    card: Optional[CardProductResponse] = None
    
    class Config:
        from_attributes = True

# Transaction Schemas
class TransactionCreate(BaseModel):
    merchant_name: str
    merchant_category: str
    amount: int
    approved_at: datetime
    is_offline_card: bool = False
    is_cancelled: bool = False

class TransactionResponse(BaseModel):
    id: str
    user_id: str
    card_id: str
    merchant_name: str
    merchant_category: str
    amount: int
    approved_at: datetime
    is_offline_card: bool
    is_cancelled: bool
    
    class Config:
        from_attributes = True

# Performance Schemas
class PerformanceSummary(BaseModel):
    current_spending: int
    remaining_amount: int
    current_tier: Optional[str] = None
    next_tier: Optional[str] = None
    tiers: List[TierInfo]

class TransactionWithClassification(BaseModel):
    id: str
    merchant_name: str
    approved_at: datetime
    amount: int
    is_counted_for_performance: bool
    is_counted_for_benefit: bool
    reason: Optional[str] = None
    performance_amount: int

class PerformanceResponse(BaseModel):
    summary: PerformanceSummary
    recognized: List[TransactionWithClassification]
    excluded: List[TransactionWithClassification]

# Benefit Schemas
class BenefitSummaryResponse(BaseModel):
    total_benefit: int
    card_benefits: List[Dict[str, Any]]

class BenefitRankResponse(BaseModel):
    percentile: float
    total_spending_1y: int
    total_benefit_1y: int
    discount_rate: float
    average_discount_rate: float

# Recommendation Schemas
class CurrentRecommendationResponse(BaseModel):
    card_id: str
    card_name: str
    merchant_name: str
    benefit_description: str
    expected_benefit: int

class MissedBenefitResponse(BaseModel):
    transaction_id: str
    date: datetime
    merchant_name: str
    used_card_id: str
    used_card_name: str
    recommended_card_id: str
    recommended_card_name: str
    missed_amount: int

# Badge Schemas
class BadgeResponse(BaseModel):
    id: str
    name: str
    description: str
    icon_emoji: str
    tier: str
    condition_type: str
    condition_value: Dict[str, Any]
    is_earned: bool = False
    earned_at: Optional[datetime] = None
    progress: Optional[Dict[str, Any]] = None
    
    class Config:
        from_attributes = True

# Place Schemas
class PlaceResponse(BaseModel):
    id: str
    name: str
    category: str
    kakao_category: str
    address: str
    road_address: Optional[str] = None
    phone: Optional[str] = None
    lat: float
    lng: float
    distance: int  # 미터 단위
    place_url: Optional[str] = None

# Recommend Schemas
class RecommendRequest(BaseModel):
    merchant_category: str
    amount: int
    timestamp: datetime
    user_cards: List[str] = []

class RecommendResponse(BaseModel):
    card_id: str
    card_name: str
    merchant_name: str
    merchant_category: str
    benefit_description: str
    expected_benefit: int
    benefit_rate: Optional[float] = None
    conditions: Optional[str] = None  # "전월실적·월 한도 충족 시 적용 / 야간 21–09" 등

