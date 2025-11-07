/// 로컬 저장소 서비스
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class StorageService {
  static const String _keyAccessToken = 'access_token';
  static const String _keyUser = 'user';
  static const String _keyLastNotificationTime = 'last_notification_time';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== 인증 관련 =====

  /// 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    await _prefs.setString(_keyAccessToken, token);
  }

  /// 액세스 토큰 조회
  String? getAccessToken() {
    return _prefs.getString(_keyAccessToken);
  }

  /// 사용자 정보 저장
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_keyUser, json.encode(user.toJson()));
  }

  /// 사용자 정보 조회
  UserModel? getUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;
    return UserModel.fromJson(json.decode(userJson));
  }

  /// 로그아웃 (모든 인증 정보 삭제)
  Future<void> clearAuth() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyUser);
  }

  /// 로그인 여부 확인
  bool isLoggedIn() {
    return getAccessToken() != null && getUser() != null;
  }

  // ===== 알림 관련 =====

  /// 마지막 알림 시간 저장 (장소별)
  Future<void> saveLastNotificationTime(String placeId) async {
    final now = DateTime.now().toIso8601String();
    await _prefs.setString('$_keyLastNotificationTime\_$placeId', now);
  }

  /// 마지막 알림 시간 조회 (장소별)
  DateTime? getLastNotificationTime(String placeId) {
    final timeStr = _prefs.getString('$_keyLastNotificationTime\_$placeId');
    if (timeStr == null) return null;
    return DateTime.parse(timeStr);
  }

  /// 중복 알림 확인 (10분 이내)
  bool shouldShowNotification(String placeId) {
    final lastTime = getLastNotificationTime(placeId);
    if (lastTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastTime);

    // 10분 이상 경과했으면 알림 허용
    return difference.inMinutes >= 10;
  }

  // ===== 일반 설정 =====

  /// 설정 저장
  Future<void> setSetting(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    }
  }

  /// 설정 조회
  dynamic getSetting(String key) {
    return _prefs.get(key);
  }

  /// 모든 데이터 삭제
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

