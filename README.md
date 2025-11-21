# CardBuddy (카드버디)

카드 결제 내역을 기반으로 최적의 카드 추천 및 혜택 관리를 제공하는 모바일 앱

## 프로젝트 구조

```
card_buddy/
├── backend/          # FastAPI 백엔드
│   ├── app/
│   │   ├── main.py
│   │   ├── database.py
│   │   ├── models.py
│   │   ├── schemas.py
│   │   ├── routers/
│   │   └── services/
│   └── requirements.txt
└── frontend/         # Flutter 프론트엔드
    ├── lib/
    │   ├── main.dart
    │   ├── theme/
    │   ├── models/
    │   ├── services/
    │   └── screens/
    └── pubspec.yaml
```

## 주요 기능

- **위치 기반 카드 추천**: 현재 위치에서 최대 혜택을 받을 수 있는 카드 추천
- **놓친 혜택 알림**: 과거 결제 내역 기준으로 놓친 혜택 계산 및 알림
- **실적 관리**: 카드별 실적 인정/제외 관리 및 티어 추적
- **혜택 집계**: 월별/연도별 받은 혜택 통계 및 순위
- **뱃지 시스템**: 다양한 조건을 달성하여 뱃지 획득

## 시작하기

### 백엔드 실행

```bash
cd backend

# 가상환경 생성 및 활성화
python -m venv venv
source venv/bin/activate  # macOS/Linux
# 또는
venv\Scripts\activate  # Windows

# 의존성 설치
pip install -r requirements.txt

# 초기 데이터 삽입 (선택사항)
python -m app.init_data

# 서버 실행
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API 문서: http://localhost:8000/docs

### 프론트엔드 실행

```bash
cd frontend

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## 기술 스택

### 백엔드
- FastAPI (Python)
- SQLAlchemy (ORM)
- SQLite (데이터베이스)

### 프론트엔드
- Flutter/Dart
- Provider (상태 관리)
- Dio (HTTP 클라이언트)
- Geolocator (위치 서비스)

## API 엔드포인트

주요 엔드포인트:
- `GET /users/{user_id}` - 사용자 정보
- `GET /cards` - 카드 검색
- `GET /users/{user_id}/cards` - 사용자 카드 목록
- `GET /users/{user_id}/cards/{card_id}/performance?month=YYYY-MM` - 카드 실적
- `GET /users/{user_id}/recommendations/current?lat=...&lng=...` - 위치 기반 추천
- `GET /users/{user_id}/recommendations/missed` - 놓친 혜택
- `GET /users/{user_id}/benefits/summary?month=YYYY-MM` - 혜택 요약
- `GET /users/{user_id}/badges` - 뱃지 목록

전체 API 문서는 서버 실행 후 http://localhost:8000/docs 에서 확인할 수 있습니다.

## 디자인 시스템

### 컬러 팔레트
- Primary Blue 50-950 (메인 컬러)
- Primary Blue 500: 메인 버튼/하이라이트 (#2269F7)
- Primary Blue 950: 기본 텍스트 (#020E31)

### 타이포그래피
- H1: 28px, Bold
- H2: 24px, Bold
- H3: 20px, SemiBold
- Body1: 16px, Regular
- Body2: 14px, Regular
- Caption: 12px, Regular

## 라이선스

이 프로젝트는 프로토타입 버전입니다.

