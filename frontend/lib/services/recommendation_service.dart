import '../models/recommendation.dart';
import 'api_client.dart';

class RecommendationService {
  final ApiClient _apiClient = ApiClient();

  Future<CurrentRecommendation?> getCurrentRecommendation(
    String userId,
    double lat,
    double lng,
  ) async {
    try {
      final response = await _apiClient.get(
        '/users/$userId/recommendations/current',
        queryParameters: {'lat': lat, 'lng': lng},
      );
      if (response.data == null) return null;
      return CurrentRecommendation.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<MissedBenefit>> getMissedBenefits(String userId, {int limit = 10}) async {
    final response = await _apiClient.get(
      '/users/$userId/recommendations/missed',
      queryParameters: {'limit': limit},
    );
    return (response.data as List).map((json) => MissedBenefit.fromJson(json)).toList();
  }
}

