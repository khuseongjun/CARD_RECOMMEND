/// 인증 상태 관리 Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// API 서비스 프로바이더
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// 스토리지 서비스 프로바이더
final storageServiceProvider = Provider<StorageService>((ref) {
  final storage = StorageService();
  storage.init();
  return storage;
});

// 인증 상태
class AuthState {
  final UserModel? user;
  final String? accessToken;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.accessToken,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    String? accessToken,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null && accessToken != null;
}

// 인증 프로바이더
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthNotifier(this._apiService, this._storageService) : super(AuthState()) {
    _loadUserFromStorage();
  }

  /// 저장된 사용자 정보 불러오기
  Future<void> _loadUserFromStorage() async {
    final user = _storageService.getUser();
    final token = _storageService.getAccessToken();

    if (user != null && token != null) {
      state = state.copyWith(user: user, accessToken: token);
    }
  }

  /// 회원가입
  Future<bool> register({
    required String username,
    required String email,
    required String nickname,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _apiService.register(
        username: username,
        email: email,
        nickname: nickname,
        password: password,
      );

      // 회원가입 후 자동 로그인
      return await login(username: username, password: password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// 로그인
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await _apiService.login(
        username: username,
        password: password,
      );

      // 저장소에 저장
      await _storageService.saveAccessToken(authResponse.accessToken);
      await _storageService.saveUser(authResponse.user);

      state = state.copyWith(
        user: authResponse.user,
        accessToken: authResponse.accessToken,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _storageService.clearAuth();
    state = AuthState();
  }

  /// 사용자 정보 새로고침
  Future<void> refreshUser() async {
    if (state.user == null) return;

    try {
      final user = await _apiService.getUserInfo(state.user!.userId);
      await _storageService.saveUser(user);
      state = state.copyWith(user: user);
    } catch (e) {
      // 에러 무시 (현재 상태 유지)
    }
  }
}

// 인증 프로바이더 인스턴스
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(apiService, storageService);
});

