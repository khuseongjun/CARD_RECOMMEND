import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// 토스 디자인 시스템 기반 타이포그래피
/// Pretendard 스타일 폰트 사용 (Noto Sans KR)
/// t1~t7 크기 체계 (제목 → 본문 순)
class AppTypography {
  // 기본 폰트 스타일
  static TextStyle _baseStyle(double fontSize, FontWeight weight, Color color, double height, double letterSpacing) {
    return GoogleFonts.notoSansKr(
      fontSize: fontSize,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // t1: 대제목 (28px, bold)
  static TextStyle get t1 => _baseStyle(28, FontWeight.w700, AppColors.textPrimary, 1.3, -0.5);

  // t2: 제목 (24px, bold)
  static TextStyle get t2 => _baseStyle(24, FontWeight.w700, AppColors.textPrimary, 1.3, -0.3);

  // t3: 부제목 (20px, bold)
  static TextStyle get t3 => _baseStyle(20, FontWeight.w700, AppColors.textPrimary, 1.4, -0.2);

  // t4: 강조 본문 (18px, medium)
  static TextStyle get t4 => _baseStyle(18, FontWeight.w600, AppColors.textPrimary, 1.5, -0.1);

  // t5: 기본 본문 (16px, regular)
  static TextStyle get t5 => _baseStyle(16, FontWeight.w500, AppColors.textPrimary, 1.5, 0);

  // t6: 보조 본문 (14px, regular)
  static TextStyle get t6 => _baseStyle(14, FontWeight.w400, AppColors.textSecondary, 1.5, 0);

  // t7: 캡션 (12px, regular)
  static TextStyle get t7 => _baseStyle(12, FontWeight.w400, AppColors.textTertiary, 1.4, 0);

  // Legacy 호환성 (기존 코드와의 호환)
  static TextStyle get h1 => t1;
  static TextStyle get h2 => t2;
  static TextStyle get h3 => t3;
  static TextStyle get body1 => t5;
  static TextStyle get body2 => t6;
  static TextStyle get caption => t7;
  
  // 숫자 전용 스타일 (tabular numbers)
  static TextStyle number(TextStyle base) {
    return base.copyWith(
      fontFeatures: [const FontFeature.tabularFigures()],
    );
  }
}
