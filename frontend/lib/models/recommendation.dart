class CurrentRecommendation {
  final String cardId;
  final String cardName;
  final String merchantName;
  final String benefitDescription;
  final int expectedBenefit;

  CurrentRecommendation({
    required this.cardId,
    required this.cardName,
    required this.merchantName,
    required this.benefitDescription,
    required this.expectedBenefit,
  });

  factory CurrentRecommendation.fromJson(Map<String, dynamic> json) {
    return CurrentRecommendation(
      cardId: json['card_id'],
      cardName: json['card_name'],
      merchantName: json['merchant_name'],
      benefitDescription: json['benefit_description'],
      expectedBenefit: json['expected_benefit'],
    );
  }
}

class MissedBenefit {
  final String transactionId;
  final DateTime date;
  final String merchantName;
  final String usedCardId;
  final String usedCardName;
  final String recommendedCardId;
  final String recommendedCardName;
  final int missedAmount;

  MissedBenefit({
    required this.transactionId,
    required this.date,
    required this.merchantName,
    required this.usedCardId,
    required this.usedCardName,
    required this.recommendedCardId,
    required this.recommendedCardName,
    required this.missedAmount,
  });

  factory MissedBenefit.fromJson(Map<String, dynamic> json) {
    return MissedBenefit(
      transactionId: json['transaction_id'],
      date: DateTime.parse(json['date']),
      merchantName: json['merchant_name'],
      usedCardId: json['used_card_id'],
      usedCardName: json['used_card_name'],
      recommendedCardId: json['recommended_card_id'],
      recommendedCardName: json['recommended_card_name'],
      missedAmount: json['missed_amount'],
    );
  }
}

