import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';

class BenefitPreferenceWidget extends StatefulWidget {
  final User? user;
  final VoidCallback? onUpdated;

  const BenefitPreferenceWidget({
    super.key,
    this.user,
    this.onUpdated,
  });

  @override
  State<BenefitPreferenceWidget> createState() => _BenefitPreferenceWidgetState();
}

class _BenefitPreferenceWidgetState extends State<BenefitPreferenceWidget> {
  final UserService _userService = UserService();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.user?.preferredBenefitType;
  }

  final List<Map<String, String>> _benefitTypes = [
    {'value': 'discount', 'label': '할인형'},
    {'value': 'points', 'label': '적립형'},
    {'value': 'cashback', 'label': '캐시백'},
    {'value': 'mileage', 'label': '마일리지'},
  ];

  Future<void> _updatePreference(String? type) async {
    try {
      const userId = 'user_123';
      await _userService.updatePreferences(
        userId,
        preferredBenefitType: type,
      );
      setState(() {
        _selectedType = type;
      });
      widget.onUpdated?.call();
      
      final label = _benefitTypes.firstWhere((t) => t['value'] == type)['label'];
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('선호 혜택을 ${label}으로 변경했어요.')),
        );
      }
    } catch (e) {
      // 에러 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user != null
                          ? '${widget.user!.name}님이 선호하는 혜택이에요'
                          : '선호 혜택을 선택해주세요',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedType == null
                          ? '어떤 혜택이 더 좋으세요? 카드 추천과 통계에 반영됩니다.'
                          : '${_benefitTypes.firstWhere((t) => t['value'] == _selectedType)['label']} 혜택을 우선으로 추천하고 있어요.',
                      style: AppTypography.body2,
                    ),
                  ],
                ),
              ),
              if (_selectedType != null)
                TextButton(
                  onPressed: () {
                    // 수정 모드로 전환 (선택 UI 표시)
                  },
                  child: const Text('수정하기'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented Control
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: _benefitTypes.map((type) {
                final isSelected = _selectedType == type['value'];
                return Expanded(
                  child: InkWell(
                    onTap: () => _updatePreference(type['value']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type['label']!,
                        textAlign: TextAlign.center,
                        style: AppTypography.body1.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
