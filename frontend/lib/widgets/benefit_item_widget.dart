/// 혜택 아이템 위젯
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../config/app_colors.dart';

class BenefitItemWidget extends StatelessWidget {
  final BenefitModel benefit;

  const BenefitItemWidget({
    Key? key,
    required this.benefit,
  }) : super(key: key);


  Color get benefitColor {
    final title = benefit.title.toLowerCase();
    if (title.contains('커피') || title.contains('카페')) {
      return AppColors.benefitCoffee;
    } else if (title.contains('대중교통') || title.contains('버스') || title.contains('지하철')) {
      return AppColors.benefitTransport;
    } else if (title.contains('편의점')) {
      return AppColors.benefitConvenience;
    } else if (title.contains('영화')) {
      return AppColors.benefitMovie;
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: benefitColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'lib/utils/sample_icon.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 혜택 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  benefit.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                // 설명
                if (benefit.shortDesc != null)
                  Text(
                    benefit.shortDesc!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 할인율 또는 정액
          if (benefit.ratePct != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${benefit.ratePct!.toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            )
          else if (benefit.flatAmount != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${benefit.flatAmount}원',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

