import '../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<User> getUser(String userId) async {
    final response = await _apiClient.get('/users/$userId');
    return User.fromJson(response.data);
  }

  Future<User> updatePreferences(String userId, {String? preferredBenefitType}) async {
    final response = await _apiClient.patch(
      '/users/$userId/preferences',
      data: {
        if (preferredBenefitType != null) 'preferred_benefit_type': preferredBenefitType,
      },
    );
    return User.fromJson(response.data);
  }
}

