class Badge {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final String tier; // Bronze, Silver, Gold
  final String conditionType;
  final Map<String, dynamic> conditionValue;
  final bool isEarned;
  final DateTime? earnedAt;
  final Map<String, dynamic>? progress;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.tier,
    required this.conditionType,
    required this.conditionValue,
    this.isEarned = false,
    this.earnedAt,
    this.progress,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconEmoji: json['icon_emoji'],
      tier: json['tier'],
      conditionType: json['condition_type'],
      conditionValue: Map<String, dynamic>.from(json['condition_value']),
      isEarned: json['is_earned'] ?? false,
      earnedAt: json['earned_at'] != null ? DateTime.parse(json['earned_at']) : null,
      progress: json['progress'] != null ? Map<String, dynamic>.from(json['progress']) : null,
    );
  }
}

