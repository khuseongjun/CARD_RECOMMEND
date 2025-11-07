# Card Proto Backend

카드 혜택 추천 서비스 백엔드 API (FastAPI)

## 기능

- ✅ 사용자 인증 (회원가입/로그인)
- ✅ 카드 정보 관리
- ✅ 카카오 Local API 연동 (주변 장소 검색)
- ✅ 카드 혜택 추천 알고리즘
- ✅ 위치 기반 실시간 추천

## 기술 스택

- **FastAPI**: 고성능 웹 프레임워크
- **SQLAlchemy**: ORM
- **SQLite**: 데이터베이스
- **httpx**: 비동기 HTTP 클라이언트
- **Pydantic**: 데이터 검증

## 설치 및 실행

### 1. 가상환경 생성 및 활성화

```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
# venv\Scripts\activate  # Windows
```

### 2. 의존성 설치

```bash
pip install -r requirements.txt
```

### 3. 환경 변수 설정

`.env.example`을 참고하여 `.env` 파일을 생성하세요.

```bash
# .env 파일 내용
KAKAO_REST_API_KEY=your_api_key_here
DATABASE_URL=sqlite:///./database/card_proto.db
HOST=0.0.0.0
PORT=8000
DEBUG=True
```

### 4. 샘플 데이터 생성

```bash
python database/init_sample_data.py
```

### 5. 서버 실행

```bash
cd app
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

또는:

```bash
python -m app.main
```

### 6. API 문서 확인

브라우저에서 다음 주소로 접속:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API 엔드포인트

### 인증 (Auth)

- `POST /api/auth/register` - 회원가입
- `POST /api/auth/login` - 로그인
- `GET /api/auth/me/{user_id}` - 사용자 정보 조회

### 카드 (Cards)

- `GET /api/cards` - 카드 목록 조회
- `GET /api/cards/{card_id}` - 카드 상세 정보 조회
- `POST /api/users/{user_id}/cards` - 사용자 카드 등록
- `GET /api/users/{user_id}/cards` - 사용자 등록 카드 목록

### 장소 검색 (Places)

- `POST /api/places/nearby` - 주변 장소 검색 (카카오 Local API)

### 추천 (Recommend)

- `POST /api/recommend` - 카드 혜택 추천

## 데이터베이스 스키마

### 주요 테이블

- **cards**: 카드 정보
- **benefits**: 혜택 정보
- **benefit_scopes**: 혜택 적용 범위 (카테고리/MCC/브랜드)
- **time_windows**: 시간대 제한
- **spend_tiers**: 전월실적 구간별 한도
- **users**: 사용자 정보
- **user_cards**: 사용자 등록 카드

## 예제 요청

### 회원가입

```bash
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "nickname": "테스트",
    "password": "password123"
  }'
```

### 주변 장소 검색

```bash
curl -X POST "http://localhost:8000/api/places/nearby" \
  -H "Content-Type: application/json" \
  -d '{
    "lat": 37.5665,
    "lng": 126.9780,
    "radius": 120
  }'
```

### 카드 추천

```bash
curl -X POST "http://localhost:8000/api/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "merchant_category": "COFFEE",
    "merchant_name": "스타벅스 강남점",
    "amount": 5000,
    "timestamp": "2025-11-05T14:30:00",
    "lat": 37.5665,
    "lng": 126.9780
  }'
```

## 캐싱 전략

- 주변 장소 검색 결과: 30초 TTL (좌표 소수점 4자리 기준)
- 동일 장소 알림: 10분 중복 방지
- 최소 절약액: 300원 이상만 노출

## 개발 노트

- 프로토타입이므로 인증은 간단한 토큰 방식 사용 (실제 프로덕션에서는 JWT 권장)
- 카카오 API 키는 환경변수로 관리
- SQLite 사용 (프로덕션에서는 PostgreSQL/MySQL 권장)

