/// 추천 모델
class RecommendationModel {
  final int cardId;
  final String cardName;
  final String cardIssuer;
  final String? cardImageUrl;
  final String benefitTitle;
  final String benefitDesc;
  final int expectedSaving;
  final double? discountRate;
  final List<String> conditions;
  final int priority;

  RecommendationModel({
    required this.cardId,
    required this.cardName,
    required this.cardIssuer,
    this.cardImageUrl,
    required this.benefitTitle,
    required this.benefitDesc,
    required this.expectedSaving,
    this.discountRate,
    required this.conditions,
    required this.priority,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      cardId: json['card_id'],
      cardName: json['card_name'],
      cardIssuer: json['card_issuer'],
      cardImageUrl: json['card_image_url'],
      benefitTitle: json['benefit_title'],
      benefitDesc: json['benefit_desc'],
      expectedSaving: json['expected_saving'],
      discountRate: json['discount_rate']?.toDouble(),
      conditions: List<String>.from(json['conditions'] ?? []),
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'card_name': cardName,
      'card_issuer': cardIssuer,
      'card_image_url': cardImageUrl,
      'benefit_title': benefitTitle,
      'benefit_desc': benefitDesc,
      'expected_saving': expectedSaving,
      'discount_rate': discountRate,
      'conditions': conditions,
      'priority': priority,
    };
  }
}

/// 추천 응답
class RecommendationResponse {
  final List<RecommendationModel> recommendations;
  final String? merchantName;
  final String merchantCategory;

  RecommendationResponse({
    required this.recommendations,
    this.merchantName,
    required this.merchantCategory,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      recommendations: (json['recommendations'] as List)
          .map((r) => RecommendationModel.fromJson(r))
          .toList(),
      merchantName: json['merchant_name'],
      merchantCategory: json['merchant_category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'merchant_name': merchantName,
      'merchant_category': merchantCategory,
    };
  }
}

/// 장소 모델
class PlaceModel {
  final String placeId;
  final String placeName;
  final String categoryName;
  final String? categoryGroupCode;
  final String? categoryGroupName;
  final String? phone;
  final String addressName;
  final String? roadAddressName;
  final String x; // longitude
  final String y; // latitude
  final String? distance;

  PlaceModel({
    required this.placeId,
    required this.placeName,
    required this.categoryName,
    this.categoryGroupCode,
    this.categoryGroupName,
    this.phone,
    required this.addressName,
    this.roadAddressName,
    required this.x,
    required this.y,
    this.distance,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      placeId: json['place_id'] ?? json['id'] ?? '',
      placeName: json['place_name'],
      categoryName: json['category_name'],
      categoryGroupCode: json['category_group_code'],
      categoryGroupName: json['category_group_name'],
      phone: json['phone'],
      addressName: json['address_name'],
      roadAddressName: json['road_address_name'],
      x: json['x'],
      y: json['y'],
      distance: json['distance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'place_name': placeName,
      'category_name': categoryName,
      'category_group_code': categoryGroupCode,
      'category_group_name': categoryGroupName,
      'phone': phone,
      'address_name': addressName,
      'road_address_name': roadAddressName,
      'x': x,
      'y': y,
      'distance': distance,
    };
  }
}

