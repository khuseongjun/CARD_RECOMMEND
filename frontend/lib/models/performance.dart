class TierInfo {
  final String code;
  final String label;
  final int minAmount;
  final int? maxAmount;

  TierInfo({
    required this.code,
    required this.label,
    required this.minAmount,
    this.maxAmount,
  });

  factory TierInfo.fromJson(Map<String, dynamic> json) {
    return TierInfo(
      code: json['code'],
      label: json['label'],
      minAmount: json['min_amount'],
      maxAmount: json['max_amount'],
    );
  }
}

class PerformanceSummary {
  final int currentSpending;
  final int remainingAmount;
  final String? currentTier;
  final String? nextTier;
  final List<TierInfo> tiers;

  PerformanceSummary({
    required this.currentSpending,
    required this.remainingAmount,
    this.currentTier,
    this.nextTier,
    required this.tiers,
  });

  factory PerformanceSummary.fromJson(Map<String, dynamic> json) {
    return PerformanceSummary(
      currentSpending: json['current_spending'],
      remainingAmount: json['remaining_amount'],
      currentTier: json['current_tier'],
      nextTier: json['next_tier'],
      tiers: (json['tiers'] as List).map((t) => TierInfo.fromJson(t)).toList(),
    );
  }
}

class TransactionWithClassification {
  final String id;
  final String merchantName;
  final DateTime approvedAt;
  final int amount;
  final bool isCountedForPerformance;
  final bool isCountedForBenefit;
  final String? reason;
  final int performanceAmount;

  TransactionWithClassification({
    required this.id,
    required this.merchantName,
    required this.approvedAt,
    required this.amount,
    required this.isCountedForPerformance,
    required this.isCountedForBenefit,
    this.reason,
    required this.performanceAmount,
  });

  factory TransactionWithClassification.fromJson(Map<String, dynamic> json) {
    return TransactionWithClassification(
      id: json['id'],
      merchantName: json['merchant_name'],
      approvedAt: DateTime.parse(json['approved_at']),
      amount: json['amount'],
      isCountedForPerformance: json['is_counted_for_performance'],
      isCountedForBenefit: json['is_counted_for_benefit'],
      reason: json['reason'],
      performanceAmount: json['performance_amount'],
    );
  }
}

class PerformanceResponse {
  final PerformanceSummary summary;
  final List<TransactionWithClassification> recognized;
  final List<TransactionWithClassification> excluded;

  PerformanceResponse({
    required this.summary,
    required this.recognized,
    required this.excluded,
  });

  factory PerformanceResponse.fromJson(Map<String, dynamic> json) {
    return PerformanceResponse(
      summary: PerformanceSummary.fromJson(json['summary']),
      recognized: (json['recognized'] as List)
          .map((t) => TransactionWithClassification.fromJson(t))
          .toList(),
      excluded: (json['excluded'] as List)
          .map((t) => TransactionWithClassification.fromJson(t))
          .toList(),
    );
  }
}

