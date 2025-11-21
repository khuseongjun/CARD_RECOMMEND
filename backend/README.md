# CardBuddy Backend

FastAPI 기반 백엔드 서버

## 설치 및 실행

```bash
# 가상환경 생성
python -m venv venv

# 가상환경 활성화
source venv/bin/activate  # macOS/Linux
# 또는
venv\Scripts\activate  # Windows

# 의존성 설치
pip install -r requirements.txt

# 서버 실행
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## API 문서

서버 실행 후 다음 URL에서 API 문서 확인:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 데이터베이스

SQLite 데이터베이스 (`card_buddy.db`)가 프로젝트 루트에 자동 생성됩니다.

## 주요 엔드포인트

- `GET /users/{user_id}` - 사용자 정보 조회
- `PATCH /users/{user_id}/preferences` - 사용자 선호 설정 업데이트
- `GET /cards` - 카드 검색
- `GET /users/{user_id}/cards` - 사용자 카드 목록
- `POST /users/{user_id}/cards` - 카드 추가
- `GET /users/{user_id}/cards/{card_id}/performance?month=YYYY-MM` - 카드 실적 조회
- `GET /users/{user_id}/benefits/summary?month=YYYY-MM` - 혜택 요약
- `GET /users/{user_id}/recommendations/current?lat=...&lng=...` - 위치 기반 추천
- `GET /users/{user_id}/recommendations/missed` - 놓친 혜택
- `GET /users/{user_id}/badges` - 뱃지 목록

