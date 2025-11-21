import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/badge_service.dart';
import '../../services/user_service.dart';
import '../../models/badge.dart' as models;
import '../../models/user.dart';

class BadgeManageScreen extends StatefulWidget {
  const BadgeManageScreen({super.key});

  @override
  State<BadgeManageScreen> createState() => _BadgeManageScreenState();
}

class _BadgeManageScreenState extends State<BadgeManageScreen> {
  final BadgeService _badgeService = BadgeService();
  final UserService _userService = UserService();
  
  List<models.Badge> _badges = [];
  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      const userId = 'user_123';
      _user = await _userService.getUser(userId);
      _badges = await _badgeService.getUserBadges(userId);
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gold 이상 뱃지 필터링
    final goldBadges = _badges.where((b) => 
      b.isEarned && (b.tier == 'Gold' || b.tier == 'Silver')
    ).toList();
    
    final representativeBadge = goldBadges.isNotEmpty
        ? goldBadges.firstWhere(
            (b) => b.id == _user?.representativeBadgeId,
            orElse: () => goldBadges.first,
          )
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('뱃지', style: AppTypography.t3),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 대표 뱃지
                  Text('나의 대표 뱃지', style: AppTypography.t3),
                  SizedBox(height: AppSpacing.sm),
                  AppComponents.card(
                    child: Column(
                      children: [
                        if (goldBadges.isEmpty || representativeBadge == null)
                          Column(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '아직 대표로 설정한 뱃지가 없어요.',
                                style: AppTypography.body1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '골드 뱃지부터 대표로 설정할 수 있어요.',
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              GestureDetector(
                                onTap: _showRepresentativeBadgeSelector,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlueLight,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryBlue,
                                      width: 3,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      representativeBadge.iconEmoji,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                representativeBadge.name,
                                style: AppTypography.h3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                representativeBadge.description,
                                style: AppTypography.body2,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _showRepresentativeBadgeSelector,
                                child: const Text('대표 뱃지 변경'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  // 전체 뱃지 그리드
                  Text('나의 뱃지', style: AppTypography.t3),
                  SizedBox(height: AppSpacing.sm),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _badges.length,
                    itemBuilder: (context, index) {
                      final badge = _badges[index];
                      return _buildBadgeItem(badge);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBadgeItem(models.Badge badge) {
    final isEarned = badge.isEarned;
    
    return GestureDetector(
      onTap: () => _showBadgeDetail(badge),
      child: AppComponents.card(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  badge.iconEmoji,
                  style: TextStyle(
                    fontSize: 40,
                    color: isEarned ? null : AppColors.textTertiary,
                  ),
                ),
                if (!isEarned)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isEarned ? AppColors.textPrimary : AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(models.Badge badge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.iconEmoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(badge.name, style: AppTypography.h2),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTierColor(badge.tier),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge.tier,
                style: AppTypography.caption.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.description,
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
            if (badge.progress != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: badge.progress!['progress'] as double? ?? 0.0,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
              const SizedBox(height: 8),
              Text(
                '${badge.progress!['current']}/${badge.progress!['target']}',
                style: AppTypography.body2,
              ),
            ],
            if (badge.isEarned && badge.earnedAt != null) ...[
              const SizedBox(height: 16),
              Text(
                '획득일: ${badge.earnedAt!.toString().split(' ')[0]}',
                style: AppTypography.caption,
              ),
            ],
            if (badge.isEarned && (badge.tier == 'Gold' || badge.tier == 'Silver')) ...[
              const SizedBox(height: 24),
              AppComponents.primaryButton(
                text: '대표 뱃지로 설정',
                onPressed: () async {
                  try {
                    const userId = 'user_123';
                    await _badgeService.setRepresentativeBadge(userId, badge.id);
                    Navigator.pop(context);
                    _loadData();
                  } catch (e) {
                    // 에러 처리
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRepresentativeBadgeSelector() {
    final goldBadges = _badges.where((b) => 
      b.isEarned && (b.tier == 'Gold' || b.tier == 'Silver')
    ).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('대표 뱃지 선택', style: AppTypography.h2),
            const SizedBox(height: 16),
            if (goldBadges.isEmpty)
              const Text('설정 가능한 뱃지가 없습니다.')
            else
              ...goldBadges.map<Widget>((badge) {
                final isSelected = badge.id == _user?.representativeBadgeId;
                return ListTile(
                  leading: Text(badge.iconEmoji, style: const TextStyle(fontSize: 32)),
                  title: Text(badge.name),
                  subtitle: Text(badge.description),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primaryBlue)
                      : null,
                  onTap: () async {
                    try {
                      const userId = 'user_123';
                      await _badgeService.setRepresentativeBadge(userId, badge.id);
                      Navigator.pop(context);
                      _loadData();
                    } catch (e) {
                      // 에러 처리
                    }
                  },
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.grey;
      case 'Bronze':
        return Colors.brown;
      default:
        return AppColors.primaryBlue;
    }
  }
}
