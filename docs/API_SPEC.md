# API 명세서

## Base URL
```
http://localhost:8000
```

## 인증 (Auth)

### 회원가입
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "nickname": "테스트",
  "password": "password123"
}
```

**응답**
```json
{
  "user_id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "nickname": "테스트",
  "created_at": "2025-11-05T10:00:00"
}
```

### 로그인
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "password123"
}
```

**응답**
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "user": {
    "user_id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "nickname": "테스트"
  }
}
```

### 사용자 정보 조회
```http
GET /api/auth/me/{user_id}
```

## 카드 (Cards)

### 카드 목록 조회
```http
GET /api/cards?skip=0&limit=100
```

**응답**
```json
[
  {
    "card_id": 101,
    "issuer": "신한",
    "name": "D4 카드의 정석",
    "annual_fee_text": "국내전용 12,000원",
    "min_spend_text": "전월실적 최소 30만원",
    "image_url": "https://..."
  }
]
```

### 카드 상세 정보
```http
GET /api/cards/{card_id}
```

**응답**
```json
{
  "card_id": 101,
  "issuer": "신한",
  "name": "D4 카드의 정석",
  "annual_fee_text": "국내전용 12,000원",
  "min_spend_text": "전월실적 최소 30만원",
  "image_url": "https://...",
  "benefits": [
    {
      "benefit_id": 2001,
      "card_id": 101,
      "title": "커피 55%",
      "short_desc": "스타벅스, 투썸플레이스에서 55% 청구할인",
      "benefit_type": "discount",
      "rate_pct": 55.0,
      "per_txn_discount_cap": 1000,
      "per_month": 5,
      "priority": 1,
      "scopes": [
        {
          "scope_type": "CATEGORY",
          "scope_value": "COFFEE",
          "include": true
        }
      ],
      "time_windows": []
    }
  ]
}
```

### 사용자 카드 등록
```http
POST /api/users/{user_id}/cards
Content-Type: application/json

{
  "card_id": 101
}
```

### 사용자 등록 카드 목록
```http
GET /api/users/{user_id}/cards
```

## 장소 검색 (Places)

### 주변 장소 검색
```http
POST /api/places/nearby
Content-Type: application/json

{
  "lat": 37.5665,
  "lng": 126.9780,
  "radius": 120
}
```

**응답**
```json
{
  "places": [
    {
      "place_id": "12345",
      "place_name": "스타벅스 강남점",
      "category_name": "음식점 > 카페 > 커피전문점",
      "category_group_code": "CE7",
      "category_group_name": "카페",
      "phone": "02-1234-5678",
      "address_name": "서울 강남구 역삼동",
      "road_address_name": "서울 강남구 테헤란로 123",
      "x": "127.0276",
      "y": "37.4979",
      "distance": "50"
    }
  ],
  "total_count": 1
}
```

## 추천 (Recommend)

### 카드 혜택 추천
```http
POST /api/recommend
Content-Type: application/json

{
  "user_id": 1,
  "merchant_category": "COFFEE",
  "merchant_name": "스타벅스 강남점",
  "amount": 5000,
  "timestamp": "2025-11-05T14:30:00",
  "lat": 37.5665,
  "lng": 126.9780
}
```

**응답**
```json
{
  "recommendations": [
    {
      "card_id": 101,
      "card_name": "D4 카드의 정석",
      "card_issuer": "신한",
      "card_image_url": "https://...",
      "benefit_title": "커피 55%",
      "benefit_desc": "55% 할인 / 최대 1,000원 / 예상 절약: 1,000원",
      "expected_saving": 1000,
      "discount_rate": 55.0,
      "conditions": [
        "전월실적 최소 30만원",
        "월 5회 한정"
      ],
      "priority": 1
    }
  ],
  "merchant_name": "스타벅스 강남점",
  "merchant_category": "COFFEE"
}
```

## 에러 응답

### 400 Bad Request
```json
{
  "detail": "이미 사용 중인 아이디입니다"
}
```

### 401 Unauthorized
```json
{
  "detail": "아이디 또는 비밀번호가 올바르지 않습니다"
}
```

### 404 Not Found
```json
{
  "detail": "카드를 찾을 수 없습니다"
}
```

### 500 Internal Server Error
```json
{
  "detail": "서버 오류가 발생했습니다"
}
```

## 카테고리 코드

| 코드 | 설명 |
|------|------|
| COFFEE | 커피/카페 |
| CONVENIENCE_STORE | 편의점 |
| RESTAURANT | 음식점 |
| MART | 마트 |
| GAS_STATION | 주유소 |
| SUBWAY | 지하철 |
| HOSPITAL | 병원 |
| PHARMACY | 약국 |
| BANK | 은행 |
| CULTURE | 문화시설 |

