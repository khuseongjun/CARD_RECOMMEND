from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import engine, Base
from app.routers import users, cards, user_cards, benefits, recommendations, performance, badges

# 데이터베이스 테이블 생성
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="CardBuddy API",
    description="카드버디 백엔드 API",
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

# 라우터 등록
app.include_router(users.router)
app.include_router(cards.router)
app.include_router(user_cards.router)
app.include_router(benefits.router)
app.include_router(recommendations.router)
app.include_router(performance.router)
app.include_router(badges.router)

@app.get("/")
def root():
    return {"message": "CardBuddy API", "version": "1.0.0"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

