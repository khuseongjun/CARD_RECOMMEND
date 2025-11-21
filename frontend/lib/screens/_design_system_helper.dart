/// 모든 화면에서 공통으로 사용할 디자인 시스템 헬퍼
/// 토스 디자인 시스템 기반 일관성 유지
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/components.dart';

class DesignSystemHelper {
  /// 표준 AppBar (토스 스타일)
  static PreferredSizeWidget standardAppBar({
    required BuildContext context,
    String? title,
    List<Widget>? actions,
    Widget? leading,
    Color? backgroundColor,
  }) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: title != null ? Text(title, style: AppTypography.t3) : null,
      leading: leading,
      actions: actions,
    );
  }

  /// 표준 Scaffold (토스 스타일)
  static Widget standardScaffold({
    required BuildContext context,
    PreferredSizeWidget? appBar,
    required Widget body,
    Color? backgroundColor,
    Widget? floatingActionButton,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }

  /// 표준 섹션 헤더
  static Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTypography.t3,
      ),
    );
  }

  /// 표준 빈 상태 (Empty State)
  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.t4,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTypography.t6,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 표준 로딩 상태
  static Widget loadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlue,
      ),
    );
  }
}

