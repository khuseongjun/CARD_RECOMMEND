/// 토스 디자인 시스템 기반 8px Spacing System
class AppSpacing {
  // 8px 단위 기반 spacing
  static const double xs = 4.0;   // 0.5 * 8
  static const double sm = 8.0;   // 1 * 8
  static const double md = 16.0;  // 2 * 8
  static const double lg = 24.0;  // 3 * 8
  static const double xl = 32.0; // 4 * 8
  static const double xxl = 40.0; // 5 * 8
  static const double xxxl = 48.0; // 6 * 8

  // 특수 spacing
  static const double screenPadding = 16.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 24.0;
}

/// 토스 디자인 시스템 기반 Border Radius
class AppRadius {
  static const double xs = 4.0;   // 매우 작은 요소
  static const double sm = 8.0;   // 작은 요소
  static const double md = 12.0;  // 기본
  static const double lg = 16.0;  // 카드
  static const double xl = 20.0;  // 모달
  static const double full = 9999.0; // 완전한 원형
}

