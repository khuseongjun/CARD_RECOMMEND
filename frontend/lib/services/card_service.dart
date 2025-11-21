import '../models/card_product.dart';
import '../models/user_card.dart';
import 'api_client.dart';

class CardService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CardProduct>> searchCards({String? query}) async {
    final response = await _apiClient.get('/cards', queryParameters: {
      if (query != null) 'q': query,
    });
    return (response.data as List).map((json) => CardProduct.fromJson(json)).toList();
  }

  Future<CardProduct> getCardDetails(String cardId) async {
    final response = await _apiClient.get('/cards/$cardId/details');
    return CardProduct.fromJson(response.data);
  }

  Future<List<UserCard>> getUserCards(String userId) async {
    final response = await _apiClient.get('/users/$userId/cards');
    return (response.data as List).map((json) => UserCard.fromJson(json)).toList();
  }

  Future<UserCard> addUserCard(String userId, String cardId, {String? nickname}) async {
    final response = await _apiClient.post(
      '/users/$userId/cards',
      data: {
        'card_id': cardId,
        if (nickname != null) 'nickname': nickname,
      },
    );
    return UserCard.fromJson(response.data);
  }

  Future<void> deleteUserCard(String userId, String cardId) async {
    await _apiClient.delete('/users/$userId/cards/$cardId');
  }
}

