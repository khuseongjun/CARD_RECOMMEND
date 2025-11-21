import '../models/badge.dart';
import 'api_client.dart';

class BadgeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Badge>> getUserBadges(String userId) async {
    final response = await _apiClient.get('/users/$userId/badges');
    return (response.data as List).map((json) => Badge.fromJson(json)).toList();
  }

  Future<Badge> getBadgeDetail(String userId, String badgeId) async {
    final response = await _apiClient.get('/users/$userId/badges/badges/$badgeId');
    return Badge.fromJson(response.data);
  }

  Future<void> setRepresentativeBadge(String userId, String badgeId) async {
    await _apiClient.patch('/users/$userId/badges/representative', data: {'badge_id': badgeId});
  }
}

