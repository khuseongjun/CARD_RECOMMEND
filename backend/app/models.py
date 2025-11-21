from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    preferred_benefit_type = Column(String, nullable=True)  # discount, points, cashback, mileage
    representative_badge_id = Column(String, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

class CardProduct(Base):
    __tablename__ = "card_products"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    issuer = Column(String, nullable=False)
    card_type = Column(JSON, nullable=False)  # ["credit", "transport"] 등
    benefit_types = Column(JSON, nullable=False)  # ["discount"] 등
    annual_fee_domestic = Column(Integer, nullable=False)
    annual_fee_international = Column(Integer, nullable=False)
    min_monthly_spending = Column(Integer, nullable=False)
    image_url = Column(String, nullable=True)

class CardPerformanceTier(Base):
    __tablename__ = "card_performance_tiers"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    card_id = Column(String, ForeignKey("card_products.id"), nullable=False)
    tier_code = Column(String, nullable=False)  # T1, T2, T3 등
    tier_label = Column(String, nullable=False)  # 1구간, 2구간 등
    min_amount = Column(Integer, nullable=False)
    max_amount = Column(Integer, nullable=True)  # null이면 무제한

class CardBenefit(Base):
    __tablename__ = "card_benefits"
    
    id = Column(String, primary_key=True, index=True)
    card_id = Column(String, ForeignKey("card_products.id"), nullable=False)
    category = Column(String, nullable=False)  # maintenance, cafe, shopping 등
    title = Column(String, nullable=False)
    short_description = Column(Text, nullable=True)
    benefit_type = Column(String, nullable=False)  # discount, points, cashback, mileage
    rate = Column(Float, nullable=True)  # 할인율, 적립율 등 (예: 0.012 = 1.2%)
    
    # 전월 실적 조건
    previous_month_min_spending = Column(Integer, nullable=True)  # 전월 최소 사용금액
    
    # 월 한도
    monthly_usage_limit = Column(Integer, nullable=True)  # 월 최대 이용금액
    monthly_discount_limit = Column(Integer, nullable=True)  # 월 최대 할인금액
    
    # 분기별 추가 할인
    quarterly_bonus_enabled = Column(Boolean, default=False)
    quarterly_bonus_condition = Column(JSON, nullable=True)  # {"monthly_min": 100000, "months": 3}
    quarterly_bonus_amount = Column(Integer, nullable=True)  # 분기별 최대 할인금액
    
    # 제외 업종/가맹점
    excluded_merchants = Column(JSON, nullable=True)  # 제외 업종 리스트
    
    # 시간 조건
    time_condition = Column(JSON, nullable=True)  # {"start": "21:00", "end": "09:00"}
    
    # 상세 설명
    detail_description = Column(Text, nullable=True)
    raw_description = Column(Text, nullable=True)

class UserCard(Base):
    __tablename__ = "user_cards"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    card_id = Column(String, ForeignKey("card_products.id"), nullable=False)
    nickname = Column(String, nullable=True)
    registered_at = Column(DateTime, server_default=func.now())

class Transaction(Base):
    __tablename__ = "transactions"
    
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    card_id = Column(String, ForeignKey("card_products.id"), nullable=False)
    merchant_name = Column(String, nullable=False)
    merchant_category = Column(String, nullable=False)
    amount = Column(Integer, nullable=False)
    approved_at = Column(DateTime, nullable=False)
    is_offline_card = Column(Boolean, default=False)
    is_cancelled = Column(Boolean, default=False)

class PerformanceClassification(Base):
    __tablename__ = "performance_classifications"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    transaction_id = Column(String, ForeignKey("transactions.id"), nullable=False)
    card_id = Column(String, ForeignKey("card_products.id"), nullable=False)
    is_counted_for_performance = Column(Boolean, default=True)
    is_counted_for_benefit = Column(Boolean, default=True)
    reason = Column(String, nullable=True)
    performance_amount = Column(Integer, nullable=False)

class BenefitAggregation(Base):
    __tablename__ = "benefit_aggregations"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    transaction_id = Column(String, ForeignKey("transactions.id"), nullable=False)
    card_id = Column(String, ForeignKey("card_products.id"), nullable=False)
    card_benefit_id = Column(String, ForeignKey("card_benefits.id"), nullable=False)
    benefit_type = Column(String, nullable=False)
    benefit_amount = Column(Integer, nullable=False)
    calculated_at = Column(DateTime, server_default=func.now())

class Badge(Base):
    __tablename__ = "badges"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    icon_emoji = Column(String, nullable=False)
    tier = Column(String, nullable=False)  # Bronze, Silver, Gold
    condition_type = Column(String, nullable=False)  # benefit_amount, transaction_count 등
    condition_value = Column(JSON, nullable=False)  # 조건 값들

class UserBadge(Base):
    __tablename__ = "user_badges"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    badge_id = Column(String, ForeignKey("badges.id"), nullable=False)
    earned_at = Column(DateTime, server_default=func.now())

