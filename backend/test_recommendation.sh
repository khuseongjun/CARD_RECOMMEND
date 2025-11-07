#!/bin/bash

# 카드 혜택 추천 테스트 스크립트

API_URL="http://localhost:8000"

echo "=========================================="
echo "🧪 Card Proto API 테스트"
echo "=========================================="
echo ""

# 1. 회원가입
echo "1️⃣ 회원가입..."
curl -s -X POST "$API_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@test.com",
    "nickname": "테스트유저",
    "password": "test1234"
  }' | jq '.'

echo ""
echo "=========================================="
echo ""

# 2. 로그인
echo "2️⃣ 로그인..."
curl -s -X POST "$API_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "test1234"
  }' | jq '.'

echo ""
echo "=========================================="
echo ""

# 3. 카드 등록
echo "3️⃣ D4 카드 등록..."
curl -s -X POST "$API_URL/api/users/1/cards" \
  -H "Content-Type: application/json" \
  -d '{
    "card_id": 101
  }' | jq '.'

echo ""
echo "=========================================="
echo ""

# 4. 주변 장소 검색
echo "4️⃣ 주변 장소 검색 (서울시청)..."
curl -s -X POST "$API_URL/api/places/nearby" \
  -H "Content-Type: application/json" \
  -d '{
    "lat": 37.5665,
    "lng": 126.9780,
    "radius": 120
  }' | jq '.places[:3]'

echo ""
echo "=========================================="
echo ""

# 5. 커피숍 추천 (낮)
echo "5️⃣ 커피숍 추천 (낮 2시)..."
curl -s -X POST "$API_URL/api/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "merchant_category": "COFFEE",
    "merchant_name": "스타벅스 강남점",
    "amount": 5000,
    "timestamp": "2025-11-06T14:30:00",
    "lat": 37.5665,
    "lng": 126.9780
  }' | jq '.'

echo ""
echo "=========================================="
echo ""

# 6. 커피숍 추천 (밤)
echo "6️⃣ 커피숍 추천 (밤 10시)..."
curl -s -X POST "$API_URL/api/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "merchant_category": "COFFEE",
    "merchant_name": "스타벅스 강남점",
    "amount": 5000,
    "timestamp": "2025-11-06T22:00:00",
    "lat": 37.5665,
    "lng": 126.9780
  }' | jq '.'

echo ""
echo "=========================================="
echo ""

# 7. 편의점 추천
echo "7️⃣ 편의점 추천..."
curl -s -X POST "$API_URL/api/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "merchant_category": "CONVENIENCE_STORE",
    "merchant_name": "CU 역삼점",
    "amount": 10000,
    "timestamp": "2025-11-06T14:30:00",
    "lat": 37.5665,
    "lng": 126.9780
  }' | jq '.'

echo ""
echo "=========================================="
echo "✅ 테스트 완료!"
echo "=========================================="

