# 🚀 빠른 시작 가이드

Card Proto 앱을 5분 안에 실행해보세요!

## 📋 사전 요구사항

### 필수 설치
- ✅ Python 3.8 이상
- ✅ Flutter SDK 3.0 이상
- ✅ iOS 시뮬레이터 또는 Android 에뮬레이터

### 확인 명령어
```bash
python3 --version
flutter --version
flutter devices
```

## 1️⃣ 백엔드 실행 (5분)

### Step 1: 디렉토리 이동
```bash
cd /Users/yunchan/card_proto/backend
```

### Step 2: 가상환경 생성
```bash
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
```

### Step 3: 패키지 설치
```bash
pip install -r requirements.txt
```

### Step 4: 샘플 데이터 생성
```bash
python database/init_sample_data.py
```

출력 예시:
```
✅ 샘플 데이터 생성 완료!
  - D4 카드의 정석 (ID: 101) - 4개 혜택
  - Mr.Life 카드 (ID: 102) - 1개 혜택
```

### Step 5: 서버 실행
```bash
cd app
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

✅ **성공!** 브라우저에서 http://localhost:8000/docs 접속하여 API 문서 확인

---

## 2️⃣ 프론트엔드 실행 (3분)

**새 터미널 창을 열어주세요!**

### Step 1: 디렉토리 이동
```bash
cd /Users/yunchan/card_proto/frontend
```

### Step 2: Flutter 패키지 설치
```bash
flutter pub get
```

### Step 3: API 설정 확인

**Android 에뮬레이터 사용 시:**
```bash
# lib/config/api_config.dart 파일 수정
# baseUrl을 'http://10.0.2.2:8000'으로 변경
```

**iOS 시뮬레이터 사용 시:**
```bash
# 변경 불필요 (localhost 사용 가능)
```

### Step 4: 앱 실행
```bash
# 연결된 디바이스 확인
flutter devices

# 실행
flutter run
```

에뮬레이터가 자동으로 열리고 앱이 시작됩니다!

---

## 3️⃣ 앱 사용하기

### 1. 회원가입
- 앱 실행 → "회원가입" 클릭
- 정보 입력:
  - 아이디: testuser
  - 이메일: test@test.com
  - 닉네임: 테스트
  - 비밀번호: test1234

### 2. 카드 등록
- 홈 화면 → "카드 추가" 클릭
- D4 카드의 정석 선택 → 클릭하여 등록

### 3. 위치 권한 허용
- "위치 권한이 필요합니다" 팝업 → "허용"

### 4. 추천 확인
- **iOS 시뮬레이터**: 
  ```
  Features → Location → Custom Location
  위도: 37.5665, 경도: 126.9780 (서울시청)
  ```
- **Android 에뮬레이터**:
  ```
  ... (More) → Location → 위치 입력
  ```

- 홈 화면 상단에 추천 배너가 표시됩니다!

---

## 🐛 문제 해결

### Q1: "flutter: command not found"
```bash
# Flutter 설치 필요
# https://docs.flutter.dev/get-started/install
```

### Q2: "No devices available"
```bash
# iOS 시뮬레이터 열기
open -a Simulator

# 또는 Android 에뮬레이터
# Android Studio → AVD Manager → 디바이스 실행
```

### Q3: API 연결 안 됨
```bash
# 백엔드 서버가 실행 중인지 확인
curl http://localhost:8000

# Android의 경우 api_config.dart 확인
# baseUrl: 'http://10.0.2.2:8000'
```

### Q4: 위치 권한 문제
```bash
# iOS: Info.plist에 권한 추가 필요 (이미 포함됨)
# Android: AndroidManifest.xml 확인 (이미 포함됨)

# 에뮬레이터 재시작
```

### Q5: "Database is locked"
```bash
# 백엔드 재시작
cd backend/app
# Ctrl+C로 종료 후
uvicorn main:app --reload
```

---

## 📱 테스트 시나리오

### 시나리오 1: 커피숍 추천
1. 위치를 카페 근처로 설정
2. 홈 화면에서 "D4 카드 / 커피 55%" 추천 확인
3. 배너 클릭 → 카드 상세 화면 이동

### 시나리오 2: 편의점 추천
1. 위치를 편의점 근처로 설정
2. "D4 카드 / 편의점 11%" 추천 확인

### 시나리오 3: 중복 알림 방지
1. 동일 위치에서 10분 대기
2. 추천 배너가 다시 나타나지 않음 (정상)

---

## 🎯 다음 단계

### 데이터 추가
```bash
# backend/database/init_sample_data.py 수정
# 새로운 카드와 혜택 추가
python database/init_sample_data.py
```

### API 문서 확인
```
http://localhost:8000/docs
```

### 코드 수정
- 백엔드: `backend/app/`
- 프론트엔드: `frontend/lib/`

---

## 📞 도움이 필요하신가요?

1. **API 문서**: http://localhost:8000/docs
2. **프로젝트 README**: `/Users/yunchan/card_proto/README.md`
3. **백엔드 README**: `/Users/yunchan/card_proto/backend/README.md`
4. **프론트엔드 README**: `/Users/yunchan/card_proto/frontend/README.md`

---

**축하합니다! 🎉 Card Proto가 정상적으로 실행되었습니다!**

