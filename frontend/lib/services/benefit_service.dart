import 'api_client.dart';

class BenefitService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getBenefitSummary(String userId, String month) async {
    final response = await _apiClient.get(
      '/users/$userId/benefits/summary',
      queryParameters: {'month': month},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getBenefitRank(String userId, {String period = '1y'}) async {
    final response = await _apiClient.get(
      '/users/$userId/benefits/rank',
      queryParameters: {'period': period},
    );
    return response.data;
  }
}

