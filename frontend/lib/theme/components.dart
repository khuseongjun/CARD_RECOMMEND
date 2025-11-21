import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// 토스 디자인 시스템 기반 컴포넌트
class AppComponents {
  /// Button 컴포넌트
  /// Variant: fill (채도 높음), weak (채도 낮음)
  /// Size: small, medium, large, xlarge
  /// Color: primary, dark, danger, light
  static Widget button({
    required String text,
    required VoidCallback onPressed,
    String variant = 'fill', // fill, weak
    String size = 'medium', // small, medium, large, xlarge
    String color = 'primary', // primary, dark, danger, light
    bool isEnabled = true,
    double? width,
    bool isFullWidth = false,
  }) {
    // Size 설정
    double height = 48.0;
    double fontSize = 16.0;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    
    switch (size) {
      case 'small':
        height = 36.0;
        fontSize = 14.0;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        break;
      case 'large':
        height = 52.0;
        fontSize = 16.0;
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
        break;
      case 'xlarge':
        height = 56.0;
        fontSize = 18.0;
        padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
        break;
      default: // medium
        height = 48.0;
        fontSize = 16.0;
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }

    // Color 설정
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (variant == 'fill') {
      switch (color) {
        case 'dark':
          backgroundColor = AppColors.grey800;
          textColor = Colors.white;
          break;
        case 'danger':
          backgroundColor = AppColors.error;
          textColor = Colors.white;
          break;
        case 'light':
          backgroundColor = AppColors.grey100;
          textColor = AppColors.textPrimary;
          break;
        default: // primary
          backgroundColor = AppColors.primaryBlue;
          textColor = Colors.white;
      }
      borderColor = backgroundColor;
    } else { // weak
      backgroundColor = Colors.transparent;
      switch (color) {
        case 'dark':
          textColor = AppColors.grey800;
          borderColor = AppColors.grey300;
          break;
        case 'danger':
          textColor = AppColors.error;
          borderColor = AppColors.error;
          break;
        case 'light':
          textColor = AppColors.textSecondary;
          borderColor = AppColors.grey300;
          break;
        default: // primary
          textColor = AppColors.primaryBlue;
          borderColor = AppColors.primaryBlue;
      }
    }

    Widget buttonWidget = Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: isEnabled ? backgroundColor : AppColors.grey200,
        border: variant == 'weak' 
          ? Border.all(
              color: isEnabled ? borderColor : AppColors.grey300,
              width: 1.5,
            )
          : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Center(
            child: Text(
              text,
              style: AppTypography.t5.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isEnabled ? textColor : AppColors.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );

    return buttonWidget;
  }

  /// Primary Button (fill + primary, 주요 CTA)
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    double? width,
    String size = 'medium',
  }) {
    return button(
      text: text,
      onPressed: onPressed,
      variant: 'fill',
      color: 'primary',
      size: size,
      isEnabled: isEnabled,
      width: width,
    );
  }

  /// Secondary Button (weak variant)
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    bool isEnabled = true,
    String size = 'medium',
  }) {
    return button(
      text: text,
      onPressed: onPressed,
      variant: 'weak',
      color: 'primary',
      size: size,
      isEnabled: isEnabled,
    );
  }

  /// Badge 컴포넌트
  /// Variant: fill, weak
  /// Size: xsmall, small, medium, large
  /// Color: blue, teal, green, red, orange, purple
  static Widget badge({
    required String text,
    String variant = 'fill',
    String size = 'medium',
    String color = 'blue',
  }) {
    double height = 28.0;
    double fontSize = 12.0;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6);

    switch (size) {
      case 'xsmall':
        height = 20.0;
        fontSize = 10.0;
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4);
        break;
      case 'small':
        height = 24.0;
        fontSize = 11.0;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        break;
      case 'large':
        height = 32.0;
        fontSize = 14.0;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
      default: // medium
        height = 28.0;
        fontSize = 12.0;
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
    }

    Color backgroundColor;
    Color textColor;

    if (variant == 'fill') {
      switch (color) {
        case 'teal':
          backgroundColor = AppColors.badgeTeal;
          textColor = AppColors.success;
          break;
        case 'green':
          backgroundColor = AppColors.badgeGreen;
          textColor = AppColors.success;
          break;
        case 'red':
          backgroundColor = AppColors.badgeRed;
          textColor = AppColors.error;
          break;
        case 'orange':
          backgroundColor = AppColors.badgeOrange;
          textColor = AppColors.warning;
          break;
        case 'purple':
          backgroundColor = AppColors.badgePurple;
          textColor = AppColors.primaryBlue;
          break;
        default: // blue
          backgroundColor = AppColors.badgeBlue;
          textColor = AppColors.primaryBlue;
      }
    } else { // weak
      backgroundColor = AppColors.grey100;
      textColor = AppColors.textSecondary;
    }

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  /// IconButton 컴포넌트
  /// Variant: clear, fill, border
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    String variant = 'clear', // clear, fill, border
    double size = 24.0,
    Color? iconColor,
    bool isEnabled = true,
  }) {
    Color defaultIconColor = iconColor ?? AppColors.textPrimary;
    
    Widget iconWidget = Icon(
      icon,
      size: size,
      color: isEnabled ? defaultIconColor : AppColors.textDisabled,
    );

    if (variant == 'clear') {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: iconWidget,
          ),
        ),
      );
    } else if (variant == 'fill') {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primaryBlue : AppColors.grey200,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Center(
              child: Icon(
                icon,
                size: size,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    } else { // border
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isEnabled ? AppColors.border : AppColors.grey300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Center(child: iconWidget),
          ),
        ),
      );
    }
  }

  /// Card 컴포넌트 (토스 스타일)
  static Widget card({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? borderRadius,
    bool hasShadow = true,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.lg),
        boxShadow: hasShadow ? [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ] : null,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: child,
    );
  }

  /// GridList 컴포넌트 (1~3 column)
  static Widget gridList({
    required List<Widget> children,
    int columns = 3,
    double spacing = 12.0,
    double childAspectRatio = 1.0,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// ListHeader 컴포넌트
  static Widget listHeader({
    String? title,
    String? rightText,
    Widget? selector,
    VoidCallback? onTextButtonTap,
    String? textButtonLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (title != null)
            Text(
              title,
              style: AppTypography.t5.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (selector != null) selector,
          if (rightText != null)
            Text(
              rightText,
              style: AppTypography.t6,
            ),
          if (onTextButtonTap != null && textButtonLabel != null)
            TextButton(
              onPressed: onTextButtonTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                textButtonLabel,
                style: AppTypography.t6.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Divider
  static Widget divider({
    double? height,
    Color? color,
  }) {
    return Divider(
      height: height ?? 1,
      thickness: 1,
      color: color ?? AppColors.divider,
    );
  }

  /// Chip 컴포넌트 (선택 가능한 칩)
  static Widget chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String size = 'medium', // small, medium, large
    IconData? icon,
  }) {
    double height = 36.0;
    double fontSize = 14.0;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    switch (size) {
      case 'small':
        height = 28.0;
        fontSize = 12.0;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
      case 'large':
        height = 44.0;
        fontSize = 16.0;
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        break;
      default: // medium
        height = 36.0;
        fontSize = 14.0;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: fontSize + 2,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton Loading (Shimmer 효과)
  static Widget skeleton({
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height ?? 16,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.sm),
      ),
    );
  }

  /// Card Skeleton (카드 모양 스켈레톤)
  static Widget cardSkeleton() {
    return card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          skeleton(width: 120, height: 20),
          const SizedBox(height: AppSpacing.md),
          skeleton(width: double.infinity, height: 16),
          const SizedBox(height: AppSpacing.sm),
          skeleton(width: 200, height: 16),
          const SizedBox(height: AppSpacing.md),
          skeleton(width: 100, height: 32, borderRadius: AppRadius.full),
        ],
      ),
    );
  }

  /// Empty State 컴포넌트
  static Widget emptyState({
    required String emoji,
    required String title,
    required String description,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.t3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSpacing.xl),
              primaryButton(
                text: buttonText,
                onPressed: onButtonPressed,
                size: 'large',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Progress Bar 컴포넌트
  static Widget progressBar({
    required double progress, // 0.0 ~ 1.0
    double height = 8.0,
    Color? backgroundColor,
    Color? progressColor,
    bool showPercentage = false,
  }) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: backgroundColor ?? AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progressColor ?? AppColors.success,
            ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// Info Box (정보 표시용 박스)
  static Widget infoBox({
    required String text,
    IconData? icon,
    String variant = 'info', // info, success, warning, error
  }) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;

    switch (variant) {
      case 'success':
        backgroundColor = AppColors.successLight;
        textColor = AppColors.badgeGreenText;
        iconColor = AppColors.success;
        break;
      case 'warning':
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.badgeOrangeText;
        iconColor = AppColors.warning;
        break;
      case 'error':
        backgroundColor = AppColors.errorLight;
        textColor = AppColors.badgeRedText;
        iconColor = AppColors.error;
        break;
      default: // info
        backgroundColor = AppColors.infoLight;
        textColor = AppColors.badgeBlueText;
        iconColor = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              text,
              style: AppTypography.body2.copyWith(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
