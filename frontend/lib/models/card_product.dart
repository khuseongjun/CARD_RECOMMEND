class CardProduct {
  final String id;
  final String name;
  final String issuer;
  final List<String> cardType;
  final List<String> benefitTypes;
  final int annualFeeDomestic;
  final int annualFeeInternational;
  final int minMonthlySpending;
  final String? imageUrl;

  CardProduct({
    required this.id,
    required this.name,
    required this.issuer,
    required this.cardType,
    required this.benefitTypes,
    required this.annualFeeDomestic,
    required this.annualFeeInternational,
    required this.minMonthlySpending,
    this.imageUrl,
  });

  factory CardProduct.fromJson(Map<String, dynamic> json) {
    return CardProduct(
      id: json['id'],
      name: json['name'],
      issuer: json['issuer'],
      cardType: List<String>.from(json['card_type']),
      benefitTypes: List<String>.from(json['benefit_types']),
      annualFeeDomestic: json['annual_fee_domestic'],
      annualFeeInternational: json['annual_fee_international'],
      minMonthlySpending: json['min_monthly_spending'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'card_type': cardType,
      'benefit_types': benefitTypes,
      'annual_fee_domestic': annualFeeDomestic,
      'annual_fee_international': annualFeeInternational,
      'min_monthly_spending': minMonthlySpending,
      'image_url': imageUrl,
    };
  }
}

