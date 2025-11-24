import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import 'home/home_screen.dart';
import 'card_manage/card_manage_screen.dart';
import 'benefit_manage/benefit_manage_screen.dart';
import 'badge_manage/badge_manage_screen.dart';
import 'auto_pay_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();

  List<Widget> get _screens => [
    HomeScreen(key: _homeScreenKey),
    const CardManageScreen(),
    const BenefitManageScreen(),
    const BadgeManageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: 250.ms,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, '홈'),
                _buildNavItem(1, Icons.credit_card_outlined, Icons.credit_card, '카드'),
                _buildNavItem(2, Icons.qr_code_scanner, Icons.qr_code_scanner, '결제'),
                _buildNavItem(3, Icons.local_offer_outlined, Icons.local_offer, '혜택'),
                _buildNavItem(4, Icons.emoji_events_outlined, Icons.emoji_events, '뱃지'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    // 현재 선택된 화면 인덱스를 기준으로 탭 활성화 상태 판단
    // 0(홈), 1(카드) -> 그대로
    // 2(결제) -> 선택 안됨 (Action)
    // 3(혜택) -> 화면인덱스 2
    // 4(뱃지) -> 화면인덱스 3
    
    bool isSelected = false;
    if (index < 2) {
      isSelected = _currentIndex == index;
    } else if (index > 2) {
      isSelected = _currentIndex == index - 1;
    }
    
    return GestureDetector(
      onTap: () {
        // 결제 탭(index 2)은 화면 전환이 아닌 모달/페이지 이동으로 처리
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AutoPayScreen()),
          );
          return;
        }

        if (_currentIndex != index) {
          // 인덱스 조정 (결제 탭이 2번이므로, 그 이후 탭들의 인덱스를 맞춰줌)
          // _screens 리스트는 4개이므로, 탭 인덱스와 매핑이 필요함
          // 0: 홈 -> 0
          // 1: 카드 -> 1
          // 2: 결제 -> (Action)
          // 3: 혜택 -> 2
          // 4: 뱃지 -> 3
          
          int screenIndex = index;
          if (index > 2) screenIndex = index - 1;

          setState(() {
            _currentIndex = screenIndex;
          });
          
          // 홈 화면으로 돌아올 때 새로고침
          if (screenIndex == 0 && _homeScreenKey.currentState != null) {
            _homeScreenKey.currentState!.refresh();
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: 200.ms,
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: !isSelected ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: -2,
                  ),
                ] : null,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : AppColors.grey500,
                size: 24,
              ),
            ).animate(target: isSelected ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 200.ms, curve: Curves.elasticOut),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.textPrimary : AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

