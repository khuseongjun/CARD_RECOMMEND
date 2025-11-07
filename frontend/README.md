  # Card Proto Frontend

카드 혜택 추천 앱 Flutter 프론트엔드

## 기능

- ✅ 사용자 인증 (회원가입/로그인)
- ✅ 카드 목록 및 상세 정보
- ✅ 사용자 카드 등록 관리
- ✅ 위치 기반 실시간 혜택 추천
- ✅ 추천 배너 알림
- ✅ 프로필 관리

## 기술 스택

- **Flutter**: 크로스 플랫폼 프레임워크
- **Riverpod**: 상태 관리
- **Dio**: HTTP 클라이언트
- **Geolocator**: 위치 서비스
- **Google Fonts**: 폰트 (Pretendard)

## 프로젝트 구조

```
lib/
├── config/             # 설정 파일
│   ├── api_config.dart
│   ├── app_colors.dart
│   └── app_theme.dart
├── models/             # 데이터 모델
│   ├── card_model.dart
│   ├── user_model.dart
│   └── recommendation_model.dart
├── services/           # 서비스 레이어
│   ├── api_service.dart
│   ├── location_service.dart
│   └── storage_service.dart
├── providers/          # Riverpod 프로바이더
│   ├── auth_provider.dart
│   └── card_provider.dart
├── screens/            # 화면
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── card_detail_screen.dart
│   ├── card_list_screen.dart
│   └── profile_screen.dart
├── widgets/            # 재사용 위젯
│   ├── app_button.dart
│   ├── app_text_field.dart
│   ├── app_badge.dart
│   ├── card_item_widget.dart
│   ├── benefit_item_widget.dart
│   └── recommendation_banner.dart
└── main.dart
```

## 설치 및 실행

### 1. Flutter 설치

Flutter SDK가 설치되어 있어야 합니다.
- [Flutter 설치 가이드](https://docs.flutter.dev/get-started/install)

### 2. 의존성 설치

```bash
cd frontend
flutter pub get
```

### 3. 백엔드 서버 실행

먼저 백엔드 서버를 실행해야 합니다.

```bash
cd ../backend/app
uvicorn main:app --reload
```

### 4. API 엔드포인트 설정

`lib/config/api_config.dart` 파일에서 API 주소를 확인/수정합니다.

```dart
static const String baseUrl = 'http://localhost:8000';
```

iOS 시뮬레이터의 경우 `localhost` 사용 가능하지만,
Android 에뮬레이터의 경우 `http://10.0.2.2:8000` 사용

### 5. 권한 설정

#### iOS (ios/Runner/Info.plist)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>주변 카드 혜택 추천을 위해 위치 권한이 필요합니다</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>주변 카드 혜택 추천을 위해 위치 권한이 필요합니다</string>
```

#### Android (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 6. 앱 실행

```bash
# iOS 시뮬레이터
flutter run -d ios

# Android 에뮬레이터
flutter run -d android

# 연결된 디바이스
flutter devices
flutter run -d <device_id>
```

## 주요 화면

### 1. 로그인/회원가입
- 이메일, 아이디, 닉네임, 비밀번호로 간단 가입
- 로그인 후 토큰 저장

### 2. 홈 화면
- 사용자 인사
- **위치 기반 추천 배너** (핵심 기능)
- 등록된 카드 목록
- 카드 추가 버튼

### 3. 위치 기반 추천 배너
- 실시간 위치 추적 (20m 이동마다 업데이트)
- 주변 가맹점 자동 감지
- 최대 혜택 카드 추천
- 예상 절약액 표시
- 중복 알림 방지 (장소별 10분)

### 4. 카드 상세
- 카드 정보 (연회비, 전월실적)
- 혜택 목록
- 혜택별 상세 조건

### 5. 프로필
- 사용자 정보 표시
- 로그아웃

## 디자인 시스템

### 색상 팔레트 (토스 스타일)
- **Primary**: #3182F6 (블루)
- **Success**: #16C784 (녹색)
- **Error**: #F04452 (빨강)
- **Background**: #F9FAFB (연한 회색)

### 컴포넌트
- **AppButton**: 커스텀 버튼
- **AppTextField**: 커스텀 입력 필드
- **AppBadge**: 뱃지
- **CardItemWidget**: 카드 아이템
- **BenefitItemWidget**: 혜택 아이템

## 위치 추적 로직

1. **초기화**: 앱 시작 시 위치 권한 요청
2. **스트림 구독**: `geolocator`의 `getPositionStream()` 사용
3. **필터링**:
   - 20m 미만 이동 시 무시
   - 20초 이내 중복 요청 방지
   - 장소별 10분 중복 알림 방지
4. **추천 요청**:
   - 주변 장소 검색 (120m 반경)
   - 가장 가까운 장소 선택
   - 카테고리 매칭
   - 최대 혜택 카드 추천
5. **배너 표시**:
   - 300원 이상 절약 시에만 표시
   - 자동으로 숨김/표시

## 개발 노트

- **상태관리**: Riverpod 사용하여 전역 상태 관리
- **네트워킹**: Dio로 RESTful API 호출
- **로컬 저장소**: SharedPreferences로 토큰, 사용자 정보 저장
- **위치**: Geolocator + PermissionHandler 조합
- **폰트**: Google Fonts - Pretendard

## 빌드

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
```

## 트러블슈팅

### 위치 권한 문제
- iOS: Info.plist에 권한 추가
- Android: AndroidManifest.xml에 권한 추가
- 실제 디바이스에서 테스트 권장

### API 연결 문제
- 백엔드 서버가 실행 중인지 확인
- Android 에뮬레이터는 `10.0.2.2` 사용
- iOS 시뮬레이터는 `localhost` 또는 Mac IP 사용

### 빌드 오류
```bash
flutter clean
flutter pub get
flutter run
```

## 참고 자료

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [Riverpod 문서](https://riverpod.dev/)
- [Geolocator 패키지](https://pub.dev/packages/geolocator)

