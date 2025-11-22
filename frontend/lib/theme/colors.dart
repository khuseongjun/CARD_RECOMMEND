import 'package:flutter/material.dart';

/// 토스 디자인 시스템 기반 색상 시스템
class AppColors {
  // Primary Blue (토스 스타일)
  static const Color primaryBlue = Color(0xFF3182F6);
  static const Color primaryBlueLight = Color(0xFFE8F3FF);
  static const Color primaryBlueDark = Color(0xFF1B64DA);
  
  // Legacy 호환성 (기존 코드와의 호환)
  static const Color primaryBlue50 = primaryBlueLight;
  static const Color primaryBlue100 = grey100;
  static const Color primaryBlue200 = grey200;
  static const Color primaryBlue300 = grey300;
  static const Color primaryBlue400 = primaryBlue;
  static const Color primaryBlue500 = primaryBlue;
  static const Color primaryBlue600 = primaryBlueDark;
  static const Color primaryBlue700 = grey700;
  static const Color primaryBlue900 = grey900;

  // Adaptive Grey (토스 스타일)
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF2F4F6);
  static const Color grey200 = Color(0xFFE5E8EB);
  static const Color grey300 = Color(0xFFD1D6DB);
  static const Color grey400 = Color(0xFFB0B8C1);
  static const Color grey500 = Color(0xFF8B95A1);
  static const Color grey600 = Color(0xFF6B7684);
  static const Color grey700 = Color(0xFF4E5968); // 기본 텍스트
  static const Color grey800 = Color(0xFF333D4B); // 강조 텍스트
  static const Color grey900 = Color(0xFF191F28);

  // Semantic Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = grey50;

  // Text Colors (토스 스타일)
  static const Color textPrimary = grey800; // 기본 텍스트
  static const Color textSecondary = grey700; // 보조 텍스트
  static const Color textTertiary = grey500; // 비활성 텍스트
  static const Color textDisabled = grey300;

  // Border & Divider
  static const Color border = grey200;
  static const Color divider = grey200;

  // Status Colors (Toss/뱅크샐러드 스타일)
  static const Color success = Color(0xFF14B896); // 토스 그린
  static const Color successLight = Color(0xFFE6FCF5);
  static const Color warning = Color(0xFFFF9500); // iOS 오렌지
  static const Color warningLight = Color(0xFFFFF4E6);
  static const Color error = Color(0xFFF04452); // 토스 레드
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = primaryBlue;
  static const Color infoLight = primaryBlueLight;

  // Vibrant Accent Colors (카드사별 브랜드 컬러)
  static const Color accentBlue = Color(0xFF3182F6); // 신한
  static const Color accentNavy = Color(0xFF1B3A6F); // KB
  static const Color accentTeal = Color(0xFF00C8B3); // 하나
  static const Color accentPurple = Color(0xFF7F5AF0); // 카카오
  static const Color accentOrange = Color(0xFFFF6B00); // 토스
  static const Color accentPink = Color(0xFFFF5D7A); // 페이코
  static const Color accentYellow = Color(0xFFFFE51F); // 카카오뱅크

  // Badge Colors (더 풍부한 팔레트)
  static const Color badgeBlue = Color(0xFFE8F3FF);
  static const Color badgeBlueText = Color(0xFF1B64DA);
  static const Color badgeTeal = Color(0xFFE6FCF5);
  static const Color badgeTealText = Color(0xFF00C8B3);
  static const Color badgeGreen = Color(0xFFE6FCF5);
  static const Color badgeGreenText = Color(0xFF14B896);
  static const Color badgeRed = Color(0xFFFFEBEE);
  static const Color badgeRedText = Color(0xFFF04452);
  static const Color badgeOrange = Color(0xFFFFF4E6);
  static const Color badgeOrangeText = Color(0xFFFF9500);
  static const Color badgePurple = Color(0xFFF3E5F5);
  static const Color badgePurpleText = Color(0xFF7F5AF0);
  static const Color badgePink = Color(0xFFFFE5EC);
  static const Color badgePinkText = Color(0xFFFF5D7A);

  // Shadow (토스 스타일 - 미세 그림자)
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
  
  // Gradient Colors (그라데이션용)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3182F6), Color(0xFF1B64DA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF14B896), Color(0xFF0DA085)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7F5AF0), Color(0xFF6B4DE0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
