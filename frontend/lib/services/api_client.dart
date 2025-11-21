import 'package:dio/dio.dart';

class ApiClient {
  // 웹에서는 localhost 대신 실제 IP나 도메인 사용 필요
  // Chrome에서 실행 시: http://127.0.0.1:8000 또는 실제 서버 주소
  static const String baseUrl = 'http://127.0.0.1:8000';
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return Exception('${error.response?.statusCode}: ${error.response?.data}');
      } else {
        return Exception('Network error: ${error.message}');
      }
    }
    return Exception('Unknown error: $error');
  }
}

