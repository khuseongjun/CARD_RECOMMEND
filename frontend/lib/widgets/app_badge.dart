/// 뱃지 위젯 (TDS 디자인 시스템)
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum BadgeType { blue, gray, red, teal, green }

class AppBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final BadgeSize size;

  const AppBadge({
    Key? key,
    required this.text,
    this.type = BadgeType.blue,
    this.size = BadgeSize.medium,
  }) : super(key: key);

  Color get backgroundColor {
    switch (type) {
      case BadgeType.blue:
        return AppColors.badgeBlue.withOpacity(0.1);
      case BadgeType.gray:
        return AppColors.badgeGray.withOpacity(0.1);
      case BadgeType.red:
        return AppColors.badgeRed.withOpacity(0.1);
      case BadgeType.teal:
        return AppColors.badgeTeal.withOpacity(0.1);
      case BadgeType.green:
        return AppColors.badgeGreen.withOpacity(0.1);
    }
  }

  Color get textColor {
    switch (type) {
      case BadgeType.blue:
        return AppColors.badgeBlue;
      case BadgeType.gray:
        return AppColors.badgeGray;
      case BadgeType.red:
        return AppColors.badgeRed;
      case BadgeType.teal:
        return AppColors.badgeTeal;
      case BadgeType.green:
        return AppColors.badgeGreen;
    }
  }

  double get fontSize {
    switch (size) {
      case BadgeSize.small:
        return 10;
      case BadgeSize.medium:
        return 12;
      case BadgeSize.large:
        return 14;
    }
  }

  EdgeInsets get padding {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

enum BadgeSize { small, medium, large }

