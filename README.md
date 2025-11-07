# Card Proto - 카드 혜택 추천 서비스

위치 기반 실시간 카드 혜택 추천 프로토타입 앱

## 📖 프로젝트 개요

사용자는 많은 카드를 보유하고 있지만 복잡한 혜택 조건 때문에 실제로 혜택을 놓치는 경우가 많습니다.
**Card Proto**는 사용자의 현재 위치를 기반으로 주변 가맹점을 자동으로 감지하고, 등록된 카드 중 최대 혜택을 받을 수 있는 카드를 실시간으로 추천합니다.

### 핵심 기능

- ✅ **위치 기반 실시간 추천**: GPS로 주변 가맹점 감지 → 최적 카드 자동 추천
- ✅ **스마트 알림**: 20m 이동마다 업데이트, 중복 알림 방지 (10분)
- ✅ **혜택 분석**: 카테고리별 할인율, 월 한도, 전월실적 조건 분석
- ✅ **직관적인 UI**: 토스 스타일의 깔끔한 디자인
- ✅ **카드 관리**: 여러 카드 등록 및 혜택 상세 정보 확인

## 🛠 기술 스택

### Backend
- **FastAPI**: Python 웹 프레임워크
- **SQLite**: 데이터베이스
- **카카오 Local API**: 장소 검색
- **SQLAlchemy**: ORM

### Frontend
- **Flutter**: 크로스 플랫폼 모바일 앱
- **Riverpod**: 상태 관리
- **Geolocator**: 위치 서비스
- **Dio**: HTTP 클라이언트

## 📂 프로젝트 구조

```
card_proto/
├── backend/                # FastAPI 백엔드
│   ├── app/
│   │   ├── config.py       # 설정
│   │   ├── database.py     # DB 모델
│   │   ├── schemas.py      # Pydantic 스키마
│   │   ├── main.py         # FastAPI 앱
│   │   ├── auth_service.py # 인증 서비스
│   │   ├── kakao_service.py # 카카오 API
│   │   ├── recommendation_service.py # 추천 로직
│   │   └── cache_service.py # 캐시
│   ├── database/
│   │   └── init_sample_data.py # 샘플 데이터
│   ├── requirements.txt
│   └── README.md
│
├── frontend/               # Flutter 프론트엔드
│   ├── lib/
│   │   ├── config/         # 설정
│   │   ├── models/         # 데이터 모델
│   │   ├── services/       # API/위치/저장소 서비스
│   │   ├── providers/      # 상태 관리
│   │   ├── screens/        # 화면
│   │   ├── widgets/        # 재사용 위젯
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
│
└── README.md               # 이 파일
```

## 🚀 빠른 시작

### 1. 백엔드 실행

```bash
# 1. 백엔드 디렉토리로 이동
cd backend

# 2. 가상환경 생성 및 활성화
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
# venv\Scripts\activate   # Windows

# 3. 의존성 설치
pip install -r requirements.txt

# 4. 샘플 데이터 생성
python database/init_sample_data.py

# 5. 서버 실행
cd app
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

서버가 실행되면 http://localhost:8000/docs 에서 API 문서를 확인할 수 있습니다.

### 2. 프론트엔드 실행

```bash
# 1. 프론트엔드 디렉토리로 이동
cd frontend

# 2. Flutter 의존성 설치
flutter pub get

# 3. 앱 실행
flutter run
```

**주의**: 
- iOS 시뮬레이터: `localhost` 사용 가능
- Android 에뮬레이터: API 주소를 `http://10.0.2.2:8000`으로 변경 필요
  (`lib/config/api_config.dart` 파일 수정)

## 📱 화면 구성

### 1. 로그인/회원가입
- 간단한 정보로 회원가입 (아이디, 이메일, 닉네임, 비밀번호)
- 로그인 후 홈 화면 이동

### 2. 홈 화면
- **위치 기반 추천 배너**: 실시간으로 최적 카드 추천 표시
- 내 카드 목록
- 카드 추가 버튼

### 3. 추천 배너 (핵심 기능)
```
🎯 지금 여기서
D4 카드의 정석
커피 55%
💰 550원 절약
전월실적 최소 30만원
```
- 현재 위치 주변 가맹점 자동 감지
- 최대 혜택 카드 실시간 추천
- 예상 절약액 표시
- 클릭 시 카드 상세 화면 이동

### 4. 카드 상세
- 카드 정보 (연회비, 전월실적)
- 혜택 목록 및 상세 조건
- 시간대/요일 제한 표시

### 5. 프로필
- 사용자 정보
- 로그아웃

## 🧠 추천 알고리즘

### 1. 위치 추적
```
사용자 이동 → GPS 좌표 업데이트 (20m 간격)
→ 카카오 Local API 호출 (120m 반경)
→ 가장 가까운 가맹점 선택
```

### 2. 혜택 필터링
```
사용자 등록 카드 조회
→ 각 카드의 혜택 목록 조회
→ 카테고리 매칭 (편의점, 커피, 대중교통 등)
→ 시간대 확인 (예: 야간 21:00~09:00)
→ 유효기간 확인
```

### 3. 혜택 계산
```
결제 금액(가정) × 할인율
→ 1회 최대 할인액 적용
→ 월 한도 고려
→ 전월실적 조건 표시
```

### 4. 최종 추천
```
예상 절약액 내림차순 정렬
→ 우선순위 적용
→ Top 1~2 카드 반환
→ 300원 이상만 배너 표시
```

### 5. 알림 정책
- 동일 장소 **10분 이내 중복 노출 금지**
- **20초 이내 중복 요청 방지**
- **예상 절약액 300원 이상**만 표시

## 📊 데이터베이스 스키마

### 주요 테이블

#### cards (카드)
- card_id, issuer, name
- annual_fee_text, min_spend_text
- image_url

#### benefits (혜택)
- benefit_id, card_id, title
- benefit_type (discount/rebate/mileage)
- rate_pct, flat_amount
- per_txn_discount_cap, per_month
- group_key, priority

#### benefit_scopes (적용 범위)
- benefit_id, scope_type
- scope_value (COFFEE, CONVENIENCE_STORE 등)
- include (포함/제외)

#### time_windows (시간대 제한)
- benefit_id, start_time, end_time
- days_of_week

#### users (사용자)
- user_id, username, email
- nickname, password_hash

#### user_cards (사용자 등록 카드)
- user_id, card_id

## 🎨 디자인 시스템

### 색상 팔레트 (토스 스타일)
- **Primary**: #3182F6 (블루)
- **Success**: #16C784 (녹색)
- **Error**: #F04452 (빨강)
- **Warning**: #FFA900 (주황)
- **Background**: #F9FAFB

### 컴포넌트
- AppButton: 기본 버튼
- AppTextField: 입력 필드
- AppBadge: 뱃지
- CardItemWidget: 카드 카드
- BenefitItemWidget: 혜택 아이템

## 📋 샘플 데이터

### D4 카드의 정석 (ID: 101)
- 커피 55% (일 1회, 월 5회)
- 대중교통 33% (일 2회, 월 10회)
- 편의점 11% (일 1회, 월 10회)
- 영화 5,500원 할인 (일 1회, 월 5회)

### Mr.Life 카드 (ID: 102)
- 커피 10% (야간 21:00~09:00, 일 1회, 월 10회)

## 🔐 보안 고려사항

- 비밀번호 SHA-256 해싱
- 위치 정보 서버 저장 금지
- 토큰 기반 인증 (프로토타입: 간단한 토큰, 실제: JWT 권장)
- API 키 환경변수 관리

## ⚠️ 제한사항 (프로토타입)

- 실제 결제 내역 연동 없음
- 전월실적 자동 추적 불가 (조건만 표시)
- 주유소 리터당 할인 등 복잡한 계산 제외
- 카드사 공식 API 미연동 (수동 데이터 입력)

## 📈 향후 개선 사항

1. **카드사 API 연동**: 실제 카드 데이터 동기화
2. **결제 내역 분석**: Open Banking API 연동
3. **전월실적 자동 추적**: 실시간 실적 계산
4. **푸시 알림**: 백그라운드에서도 추천 알림
5. **AI 추천**: 사용 패턴 학습 기반 개인화
6. **다중 카드 비교**: 여러 카드 동시 비교
7. **혜택 캘린더**: 월별 혜택 사용 현황

## 🧪 테스트

### 백엔드 API 테스트
```bash
# 회원가입
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "email": "test@test.com", "nickname": "테스트", "password": "password123"}'

# 로그인
curl -X POST "http://localhost:8000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}'

# 카드 목록 조회
curl "http://localhost:8000/api/cards"

# 주변 장소 검색
curl -X POST "http://localhost:8000/api/places/nearby" \
  -H "Content-Type: application/json" \
  -d '{"lat": 37.5665, "lng": 126.9780, "radius": 120}'
```

### 프론트엔드 테스트
1. 앱 실행 후 회원가입
2. 카드 추가 (D4 카드 등록)
3. 위치 권한 허용
4. 주변 가맹점 근처로 이동 (시뮬레이터에서 위치 변경)
5. 추천 배너 확인

## 🤝 기여

이 프로젝트는 교육용 프로토타입입니다.

## 📄 라이선스

MIT License

## 👤 개발자

- 백엔드: FastAPI + SQLite
- 프론트엔드: Flutter + Riverpod
- 위치 서비스: Geolocator
- 장소 검색: 카카오 Local API

## 📞 문의

- 이메일: support@cardproto.com
- GitHub: [card_proto](https://github.com/yourusername/card_proto)

---

**Card Proto** - 똑똑한 카드 혜택, 자동으로 추천받으세요! 🎉

