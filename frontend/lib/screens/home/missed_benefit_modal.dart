import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../models/recommendation.dart';

class MissedBenefitModal extends StatelessWidget {
  final List<MissedBenefit> missedBenefits;

  const MissedBenefitModal({
    super.key,
    required this.missedBenefits,
  });

  @override
  Widget build(BuildContext context) {
    final totalMissed = missedBenefits.fold<int>(
      0,
      (sum, benefit) => sum + benefit.missedAmount,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('놓친 혜택', style: AppTypography.h2),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 리스트
            Expanded(
              child: missedBenefits.isEmpty
                  ? Center(
                      child: Text(
                        '놓친 혜택이 없습니다.',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: missedBenefits.length,
                      itemBuilder: (context, index) {
                        final benefit = missedBenefits[index];
                        return _buildBenefitItem(benefit);
                      },
                    ),
            ),
            
            // 하단 요약
            if (missedBenefits.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '이번 달 기준, 총',
                      style: AppTypography.body2,
                    ),
                    Text(
                      '${NumberFormat('#,###').format(totalMissed)}원',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      '을 더 아낄 수 있었어요.',
                      style: AppTypography.body2,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(MissedBenefit benefit) {
    final dateStr = DateFormat('M.d (E)', 'ko').format(benefit.date);
    final timeStr = DateFormat('HH:mm').format(benefit.date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '+${NumberFormat('#,###').format(benefit.missedAmount)}원',
                style: AppTypography.body1.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            benefit.merchantName,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$timeStr ${benefit.usedCardName}로 결제했어요.',
            style: AppTypography.body2,
          ),
          const SizedBox(height: 4),
          Text(
            '${benefit.recommendedCardName} 카드로 결제했다면 ${NumberFormat('#,###').format(benefit.missedAmount)}원을 더 절약할 수 있었어요.',
            style: AppTypography.body2.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}

