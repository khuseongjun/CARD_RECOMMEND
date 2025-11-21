import 'card_product.dart';

class UserCard {
  final int id;
  final String userId;
  final String cardId;
  final String? nickname;
  final DateTime registeredAt;
  final CardProduct? card;

  UserCard({
    required this.id,
    required this.userId,
    required this.cardId,
    this.nickname,
    required this.registeredAt,
    this.card,
  });

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      id: json['id'],
      userId: json['user_id'],
      cardId: json['card_id'],
      nickname: json['nickname'],
      registeredAt: DateTime.parse(json['registered_at']),
      card: json['card'] != null ? CardProduct.fromJson(json['card']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_id': cardId,
      'nickname': nickname,
      'registered_at': registeredAt.toIso8601String(),
      'card': card?.toJson(),
    };
  }
}

