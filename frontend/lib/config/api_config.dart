/// API 설정
class ApiConfig {
  // 개발 환경
  static const String baseUrl = 'http://localhost:8000';
  
  // 프로덕션 환경 (배포 시 변경)
  // static const String baseUrl = 'https://api.cardproto.com';
  
  // API 엔드포인트
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authMe = '/api/auth/me';
  static const String cards = '/api/cards';
  static const String placesNearby = '/api/places/nearby';
  static const String recommend = '/api/recommend';
  
  // 사용자 카드
  static String userCards(int userId) => '/api/users/$userId/cards';
  static String cardDetail(int cardId) => '/api/cards/$cardId';
  
  // 타임아웃
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}

