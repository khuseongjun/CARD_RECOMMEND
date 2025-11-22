import '../models/recommend.dart';
import 'api_client.dart';

class RecommendService {
  final ApiClient _apiClient = ApiClient();

  /// 가맹점에 대한 최적 카드 추천
  Future<List<RecommendResponse>> getRecommendations({
    required String userId,
    required String merchantCategory,
    String? merchantName,
    required int amount,
    required DateTime timestamp,
    List<String>? userCards,
  }) async {
    final response = await _apiClient.post(
      '/recommend',
      data: {
        'user_id': userId,
        'merchant_category': merchantCategory,
        if (merchantName != null) 'merchant_name': merchantName,
        'amount': amount,
        'timestamp': timestamp.toIso8601String(),
        'user_cards': userCards ?? [],
      },
    );
    return (response.data as List)
        .map((json) => RecommendResponse.fromJson(json))
        .toList();
  }
}

