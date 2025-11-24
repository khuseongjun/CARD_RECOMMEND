import 'package:card_buddy/services/api_client.dart';

class AutoPayService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> simulatePayment({
    required String userId,
    required String paymentType,
  }) async {
    final response = await _client.post('/auto-pay/simulate', data: {
      'user_id': userId,
      'payment_type': paymentType,
    });
    return response.data;
  }
}
