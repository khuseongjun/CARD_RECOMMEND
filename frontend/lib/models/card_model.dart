/// 카드 모델
class CardModel {
  final int cardId;
  final String issuer;
  final String name;
  final String? annualFeeText;
  final String? minSpendText;
  final String? imageUrl;
  final List<BenefitModel>? benefits;

  CardModel({
    required this.cardId,
    required this.issuer,
    required this.name,
    this.annualFeeText,
    this.minSpendText,
    this.imageUrl,
    this.benefits,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      cardId: json['card_id'],
      issuer: json['issuer'],
      name: json['name'],
      annualFeeText: json['annual_fee_text'],
      minSpendText: json['min_spend_text'],
      imageUrl: json['image_url'],
      benefits: json['benefits'] != null
          ? (json['benefits'] as List)
              .map((b) => BenefitModel.fromJson(b))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card_id': cardId,
      'issuer': issuer,
      'name': name,
      'annual_fee_text': annualFeeText,
      'min_spend_text': minSpendText,
      'image_url': imageUrl,
      'benefits': benefits?.map((b) => b.toJson()).toList(),
    };
  }
}

/// 혜택 모델
class BenefitModel {
  final int benefitId;
  final int cardId;
  final String title;
  final String? shortDesc;
  final String? benefitType;
  final double? ratePct;
  final int? flatAmount;
  final int? perTxnAmountCap;
  final int? perTxnDiscountCap;
  final int? perDay;
  final int? perMonth;
  final String? groupKey;
  final int priority;
  final List<BenefitScopeModel>? scopes;
  final List<TimeWindowModel>? timeWindows;

  BenefitModel({
    required this.benefitId,
    required this.cardId,
    required this.title,
    this.shortDesc,
    this.benefitType,
    this.ratePct,
    this.flatAmount,
    this.perTxnAmountCap,
    this.perTxnDiscountCap,
    this.perDay,
    this.perMonth,
    this.groupKey,
    required this.priority,
    this.scopes,
    this.timeWindows,
  });

  factory BenefitModel.fromJson(Map<String, dynamic> json) {
    return BenefitModel(
      benefitId: json['benefit_id'],
      cardId: json['card_id'],
      title: json['title'],
      shortDesc: json['short_desc'],
      benefitType: json['benefit_type'],
      ratePct: json['rate_pct']?.toDouble(),
      flatAmount: json['flat_amount'],
      perTxnAmountCap: json['per_txn_amount_cap'],
      perTxnDiscountCap: json['per_txn_discount_cap'],
      perDay: json['per_day'],
      perMonth: json['per_month'],
      groupKey: json['group_key'],
      priority: json['priority'] ?? 1,
      scopes: json['scopes'] != null
          ? (json['scopes'] as List)
              .map((s) => BenefitScopeModel.fromJson(s))
              .toList()
          : null,
      timeWindows: json['time_windows'] != null
          ? (json['time_windows'] as List)
              .map((t) => TimeWindowModel.fromJson(t))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'benefit_id': benefitId,
      'card_id': cardId,
      'title': title,
      'short_desc': shortDesc,
      'benefit_type': benefitType,
      'rate_pct': ratePct,
      'flat_amount': flatAmount,
      'per_txn_amount_cap': perTxnAmountCap,
      'per_txn_discount_cap': perTxnDiscountCap,
      'per_day': perDay,
      'per_month': perMonth,
      'group_key': groupKey,
      'priority': priority,
      'scopes': scopes?.map((s) => s.toJson()).toList(),
      'time_windows': timeWindows?.map((t) => t.toJson()).toList(),
    };
  }
}

/// 혜택 적용 범위 모델
class BenefitScopeModel {
  final String scopeType;
  final String scopeValue;
  final bool include;

  BenefitScopeModel({
    required this.scopeType,
    required this.scopeValue,
    required this.include,
  });

  factory BenefitScopeModel.fromJson(Map<String, dynamic> json) {
    return BenefitScopeModel(
      scopeType: json['scope_type'],
      scopeValue: json['scope_value'],
      include: json['include'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scope_type': scopeType,
      'scope_value': scopeValue,
      'include': include,
    };
  }
}

/// 시간대 모델
class TimeWindowModel {
  final String startTime;
  final String endTime;
  final String? daysOfWeek;

  TimeWindowModel({
    required this.startTime,
    required this.endTime,
    this.daysOfWeek,
  });

  factory TimeWindowModel.fromJson(Map<String, dynamic> json) {
    return TimeWindowModel(
      startTime: json['start_time'],
      endTime: json['end_time'],
      daysOfWeek: json['days_of_week'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'days_of_week': daysOfWeek,
    };
  }
}

