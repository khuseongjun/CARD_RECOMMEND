class RecommendRequest {
  final String merchantCategory;
  final int amount;
  final DateTime timestamp;
  final List<String> userCards;

  RecommendRequest({
    required this.merchantCategory,
    required this.amount,
    required this.timestamp,
    this.userCards = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'merchant_category': merchantCategory,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'user_cards': userCards,
    };
  }
}

class RecommendResponse {
  final String cardId;
  final String cardName;
  final String merchantName;
  final String merchantCategory;
  final String benefitDescription;
  final int expectedBenefit;
  final double? benefitRate;
  final String? conditions;

  RecommendResponse({
    required this.cardId,
    required this.cardName,
    required this.merchantName,
    required this.merchantCategory,
    required this.benefitDescription,
    required this.expectedBenefit,
    this.benefitRate,
    this.conditions,
  });

  factory RecommendResponse.fromJson(Map<String, dynamic> json) {
    return RecommendResponse(
      cardId: json['card_id'],
      cardName: json['card_name'],
      merchantName: json['merchant_name'],
      merchantCategory: json['merchant_category'],
      benefitDescription: json['benefit_description'],
      expectedBenefit: json['expected_benefit'],
      benefitRate: json['benefit_rate']?.toDouble(),
      conditions: json['conditions'],
    );
  }
}

