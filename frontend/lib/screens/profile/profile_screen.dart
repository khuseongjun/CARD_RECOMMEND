import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      const userId = 'user_123';
      final user = await _userService.getUser(userId);
      setState(() {
        _user = user;
      });
    } catch (e) {
      // 에러 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('프로필', style: AppTypography.t3),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          // 사용자 정보 카드
          AppComponents.card(
            margin: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    _user?.name.substring(0, 1) ?? 'U',
                    style: AppTypography.h2.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?.name ?? '사용자',
                        style: AppTypography.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _user?.email ?? '',
                        style: AppTypography.body2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 인증 및 보안
          _buildSection(
            title: '인증 및 보안',
            items: [
              _buildMenuItem(
                title: '비밀번호 및 보안',
                icon: Icons.lock_outline,
                onTap: () {},
              ),
              _buildMenuItem(
                title: '위치 정보 설정 및 철회',
                icon: Icons.location_on_outlined,
                onTap: () {},
              ),
            ],
          ),

          // 마이데이터 관리
          _buildSection(
            title: '마이데이터 관리',
            items: [
              _buildMenuItem(
                title: '불러온 카드·금융사 관리',
                icon: Icons.credit_card_outlined,
                onTap: () {},
              ),
            ],
          ),

          // 법적 정보 및 기타
          _buildSection(
            title: '법적 정보 및 기타',
            items: [
              _buildMenuItem(
                title: '약관 및 개인정보 처리 동의',
                icon: Icons.description_outlined,
                onTap: () {},
              ),
              _buildMenuItem(
                title: '개인정보 처리방침',
                icon: Icons.privacy_tip_outlined,
                onTap: () {},
              ),
              _buildMenuItem(
                title: '위치정보 처리방침',
                icon: Icons.location_on_outlined,
                onTap: () {},
              ),
              _buildMenuItem(
                title: '탈퇴하기',
                icon: Icons.delete_outline,
                onTap: () {
                  _showDeleteConfirmDialog();
                },
                textColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.sm),
          child: Text(
            title,
            style: AppTypography.body2.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: AppTypography.body1.copyWith(color: textColor),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('탈퇴하기'),
        content: const Text('정말 탈퇴하시겠습니까? 모든 데이터가 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 탈퇴 로직
            },
            child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
