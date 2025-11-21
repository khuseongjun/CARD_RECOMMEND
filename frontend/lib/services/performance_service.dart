import '../models/performance.dart';
import 'api_client.dart';

class PerformanceService {
  final ApiClient _apiClient = ApiClient();

  Future<PerformanceResponse> getCardPerformance(
    String userId,
    String cardId,
    String month, // YYYY-MM
  ) async {
    final response = await _apiClient.get(
      '/users/$userId/cards/$cardId/performance',
      queryParameters: {'month': month},
    );
    return PerformanceResponse.fromJson(response.data);
  }
}

