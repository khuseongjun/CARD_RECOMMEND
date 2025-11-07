/// API 서비스
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/card_model.dart';
import '../models/user_model.dart';
import '../models/recommendation_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 로깅 인터셉터 (개발 환경)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // ===== 인증 API =====

  /// 회원가입
  Future<UserModel> register({
    required String username,
    required String email,
    required String nickname,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.authRegister,
        data: {
          'username': username,
          'email': email,
          'nickname': nickname,
          'password': password,
        },
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 로그인
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.authLogin,
        data: {
          'username': username,
          'password': password,
        },
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 사용자 정보 조회
  Future<UserModel> getUserInfo(int userId) async {
    try {
      final response = await _dio.get('${ApiConfig.authMe}/$userId');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ===== 카드 API =====

  /// 카드 목록 조회
  Future<List<CardModel>> getCards({int skip = 0, int limit = 100}) async {
    try {
      final response = await _dio.get(
        ApiConfig.cards,
        queryParameters: {'skip': skip, 'limit': limit},
      );
      return (response.data as List)
          .map((card) => CardModel.fromJson(card))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 카드 상세 정보 조회
  Future<CardModel> getCardDetail(int cardId) async {
    try {
      final response = await _dio.get(ApiConfig.cardDetail(cardId));
      return CardModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 사용자 카드 등록
  Future<void> registerUserCard(int userId, int cardId) async {
    try {
      await _dio.post(
        ApiConfig.userCards(userId),
        data: {'card_id': cardId},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 사용자 등록 카드 목록 조회
  Future<List<CardModel>> getUserCards(int userId) async {
    try {
      final response = await _dio.get(ApiConfig.userCards(userId));
      return (response.data as List)
          .map((card) => CardModel.fromJson(card))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 사용자 카드 삭제
  Future<void> deleteUserCard(int userId, int cardId) async {
    try {
      await _dio.delete('${ApiConfig.userCards(userId)}/$cardId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ===== 장소 검색 API =====

  /// 주변 장소 검색
  Future<List<PlaceModel>> getNearbyPlaces({
    required double lat,
    required double lng,
    int radius = 120,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.placesNearby,
        data: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
        },
      );
      return (response.data['places'] as List)
          .map((place) => PlaceModel.fromJson(place))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ===== 추천 API =====

  /// 카드 혜택 추천
  Future<RecommendationResponse> getRecommendations({
    required int userId,
    required String merchantCategory,
    String? merchantName,
    int amount = 10000,
    required String timestamp,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.recommend,
        data: {
          'user_id': userId,
          'merchant_category': merchantCategory,
          'merchant_name': merchantName,
          'amount': amount,
          'timestamp': timestamp,
          'lat': lat,
          'lng': lng,
        },
      );
      return RecommendationResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ===== 에러 처리 =====

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('detail')) {
          return data['detail'];
        }
        return '서버 오류가 발생했습니다: ${error.response!.statusCode}';
      } else {
        return '네트워크 연결을 확인해주세요';
      }
    }
    return '알 수 없는 오류가 발생했습니다';
  }
}

