class User {
  final String id;
  final String name;
  final String email;
  final String? preferredBenefitType;
  final String? representativeBadgeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.preferredBenefitType,
    this.representativeBadgeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      preferredBenefitType: json['preferred_benefit_type'],
      representativeBadgeId: json['representative_badge_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferred_benefit_type': preferredBenefitType,
      'representative_badge_id': representativeBadgeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

