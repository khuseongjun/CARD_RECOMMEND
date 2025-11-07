"""데이터베이스 연결 및 모델 정의"""
from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, Date, ForeignKey, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, relationship
from app.config import settings

# 데이터베이스 엔진 생성
engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False} if "sqlite" in settings.database_url else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# 데이터베이스 의존성
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# 모델 정의
class Card(Base):
    """카드 테이블"""
    __tablename__ = "cards"
    
    card_id = Column(Integer, primary_key=True, index=True)
    issuer = Column(String(50), nullable=False)  # 카드사
    name = Column(String(100), nullable=False)  # 카드명
    annual_fee_text = Column(String(200))  # 연회비 정보
    min_spend_text = Column(String(200))  # 전월실적
    image_url = Column(String(500))  # 카드 이미지 URL
    
    # 관계
    benefits = relationship("Benefit", back_populates="card", cascade="all, delete-orphan")
    spend_tiers = relationship("SpendTier", back_populates="card", cascade="all, delete-orphan")
    promotions = relationship("Promotion", back_populates="card", cascade="all, delete-orphan")
    exclusions = relationship("Exclusion", back_populates="card", cascade="all, delete-orphan")


class Benefit(Base):
    """혜택 테이블"""
    __tablename__ = "benefits"
    
    benefit_id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey("cards.card_id"), nullable=False)
    title = Column(String(200), nullable=False)
    short_desc = Column(String(500))
    benefit_type = Column(String(50))  # discount, rebate, mileage
    rate_pct = Column(Float)  # 할인율
    flat_amount = Column(Integer)  # 정액 할인
    per_txn_amount_cap = Column(Integer)  # 1회 결제 최대 적용금액
    per_txn_discount_cap = Column(Integer)  # 1회 할인 최대금액
    per_day = Column(Integer)  # 일 적용횟수
    per_month = Column(Integer)  # 월 적용횟수
    group_key = Column(String(50))  # 통합한도 그룹
    valid_from = Column(Date)
    valid_to = Column(Date)
    priority = Column(Integer, default=1)  # 우선순위 (낮을수록 우선)
    
    # 관계
    card = relationship("Card", back_populates="benefits")
    scopes = relationship("BenefitScope", back_populates="benefit", cascade="all, delete-orphan")
    time_windows = relationship("TimeWindow", back_populates="benefit", cascade="all, delete-orphan")


class BenefitScope(Base):
    """혜택 적용 범위 테이블"""
    __tablename__ = "benefit_scopes"
    
    scope_id = Column(Integer, primary_key=True, index=True)
    benefit_id = Column(Integer, ForeignKey("benefits.benefit_id"), nullable=False)
    scope_type = Column(String(50), nullable=False)  # CATEGORY, MCC, BRAND
    scope_value = Column(String(100), nullable=False)
    include = Column(Boolean, default=True)  # True=포함, False=제외
    
    # 관계
    benefit = relationship("Benefit", back_populates="scopes")


class TimeWindow(Base):
    """시간대 제한 테이블"""
    __tablename__ = "time_windows"
    
    window_id = Column(Integer, primary_key=True, index=True)
    benefit_id = Column(Integer, ForeignKey("benefits.benefit_id"), nullable=False)
    start_time = Column(String(5), nullable=False)  # HH:MM
    end_time = Column(String(5), nullable=False)  # HH:MM
    days_of_week = Column(String(20))  # 1|2|3|4|5|6|7 (월~일)
    
    # 관계
    benefit = relationship("Benefit", back_populates="time_windows")


class SpendTier(Base):
    """전월실적 구간별 혜택 한도 테이블"""
    __tablename__ = "spend_tiers"
    
    tier_id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey("cards.card_id"), nullable=False)
    benefit_group = Column(String(50), nullable=False)  # BILLS, ALLDAY, TIME, WEEKEND
    min_spend = Column(Integer, nullable=False)
    max_spend = Column(Integer)  # NULL이면 상한 없음
    monthly_total_cap = Column(Integer, nullable=False)  # 월 총 한도
    
    # 관계
    card = relationship("Card", back_populates="spend_tiers")


class Promotion(Base):
    """프로모션 테이블"""
    __tablename__ = "promotions"
    
    promo_id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey("cards.card_id"), nullable=False)
    name = Column(String(200), nullable=False)
    details = Column(Text)
    start_date = Column(Date)
    end_date = Column(Date)
    conditions_json = Column(Text)  # JSON 형태의 조건
    reward_json = Column(Text)  # JSON 형태의 보상
    active = Column(Boolean, default=True)
    
    # 관계
    card = relationship("Card", back_populates="promotions")


class Exclusion(Base):
    """제외 항목 테이블"""
    __tablename__ = "exclusions"
    
    excl_id = Column(Integer, primary_key=True, index=True)
    card_id = Column(Integer, ForeignKey("cards.card_id"))
    benefit_id = Column(Integer, ForeignKey("benefits.benefit_id"))
    excl_type = Column(String(50), nullable=False)  # spend_excluded, brand_excluded
    excl_code = Column(String(100), nullable=False)
    note = Column(String(500))
    
    # 관계
    card = relationship("Card", back_populates="exclusions")


class User(Base):
    """사용자 테이블"""
    __tablename__ = "users"
    
    user_id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    email = Column(String(100), unique=True, nullable=False, index=True)
    nickname = Column(String(50))
    password_hash = Column(String(255), nullable=False)
    created_at = Column(String(30))
    
    # 관계
    user_cards = relationship("UserCard", back_populates="user", cascade="all, delete-orphan")


class UserCard(Base):
    """사용자 등록 카드 테이블"""
    __tablename__ = "user_cards"
    
    user_card_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)
    card_id = Column(Integer, ForeignKey("cards.card_id"), nullable=False)
    registered_at = Column(String(30))
    
    # 관계
    user = relationship("User", back_populates="user_cards")


# 데이터베이스 초기화
def init_db():
    """데이터베이스 테이블 생성"""
    Base.metadata.create_all(bind=engine)

