import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/recommendation_service.dart';
import '../../services/user_service.dart';
import '../../services/card_service.dart';
import '../../models/user.dart';
import '../../models/recommendation.dart';
import '../../models/user_card.dart';
import '../../models/performance.dart';
import '../../services/performance_service.dart';
import '../profile/profile_screen.dart';
import '../benefit_manage/benefit_manage_screen.dart';
import '../card_manage/card_manage_screen.dart';
import '../card_performance/card_performance_screen.dart';
import '../location/location_recommendation_screen.dart';
import 'missed_benefit_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  final UserService _userService = UserService();
  final CardService _cardService = CardService();
  final PerformanceService _performanceService = PerformanceService();
  final PageController _cardPageController = PageController(viewportFraction: 0.92);
  
  User? _user;
  List<MissedBenefit> _missedBenefits = [];
  CurrentRecommendation? _currentRecommendation;
  List<UserCard> _userCards = [];
  Map<String, PerformanceResponse> _cardPerformances = {};
  bool _isLoading = false;
  bool _locationPermissionDenied = false;
  String _selectedBenefitType = 'discount';
  int _currentCardPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      const userId = 'user_123';
      _user = await _userService.getUser(userId);
      _missedBenefits = await _recommendationService.getMissedBenefits(userId);
      _userCards = await _cardService.getUserCards(userId);
      
      // 각 카드의 실적 정보 로드
      for (final userCard in _userCards) {
        try {
          final monthStr = DateFormat('yyyy-MM').format(DateTime.now());
          final performance = await _performanceService.getCardPerformance(
            userId,
            userCard.cardId,
            monthStr,
          );
          setState(() {
            _cardPerformances[userCard.cardId] = performance;
          });
        } catch (e) {
          // 실적 정보 로드 실패 시 무시
          print('실적 정보 로드 실패: $e');
        }
      }
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getLocationRecommendation() async {
    // 위치 기반 추천 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationRecommendationScreen(),
      ),
    );
  }

  bool get _isInitialState {
    return _user?.preferredBenefitType == null && _userCards.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isInitialState ? _buildInitialState() : _buildNormalState(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_missedBenefits.isNotEmpty)
            GestureDetector(
              onTap: () {
                _showMissedBenefitsModal();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '놓친혜택 ${_missedBenefits.length}건',
                  style: AppTypography.t7.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _user?.name.substring(0, 1) ?? 'U',
                  style: AppTypography.t6.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          _buildPreferenceCard(),
          SizedBox(height: AppSpacing.md),
          _buildLocationCard(),
          SizedBox(height: AppSpacing.md),
          _buildCardPerformanceCard(),
        ],
      ),
    );
  }

  Widget _buildNormalState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 놓친 혜택 알림 배너
          if (_missedBenefits.isNotEmpty) ...[
            _buildMissedBenefitBanner(),
            SizedBox(height: AppSpacing.md),
          ],
          
          // 선호 혜택 미설정 배너
          if (_user?.preferredBenefitType == null) ...[
            _buildPreferenceBanner(),
            SizedBox(height: AppSpacing.md),
          ],
          
          // 위치 기반 추천 배너
          _buildLocationRecommendationBanner(),
          SizedBox(height: AppSpacing.md),
          
          // 카드 실적 슬라이더
          if (_userCards.isNotEmpty) ...[
            Text('내 카드 실적', style: AppTypography.t3),
            SizedBox(height: AppSpacing.sm),
            _buildCardPerformanceSlider(),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferenceCard() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '할인과 적립 중 뭐가 더 좋으세요?',
            style: AppTypography.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '선호 혜택을 선택하면 카드 추천이 더 정확해져요.',
            style: AppTypography.body2.copyWith(
              fontSize: 13,
                color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppComponents.primaryButton(
            text: '선호 혜택 설정하기',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BenefitManageScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '지금 어디에 계신가요?',
            style: AppTypography.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '위치를 확인하면 최적의 카드를 추천해드려요.',
            style: AppTypography.body2.copyWith(
              fontSize: 13,
                color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppComponents.primaryButton(
            text: '위치 기반 추천 받기',
            onPressed: _getLocationRecommendation,
          ),
        ],
      ),
    );
  }

  Widget _buildCardPerformanceCard() {
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내 카드 실적',
            style: AppTypography.h3.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '카드를 등록하면 실적 정보를 확인할 수 있어요.',
            style: AppTypography.body2.copyWith(
              fontSize: 13,
                color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppComponents.primaryButton(
            text: '카드 등록하기',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CardManageScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMissedBenefitBanner() {
    return AppComponents.card(
      backgroundColor: AppColors.primaryBlue100,
      child: InkWell(
        onTap: _showMissedBenefitsModal,
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primaryBlue700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '놓친혜택 ${_missedBenefits.length}건이 있어요',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceBanner() {
    return AppComponents.card(
      backgroundColor: AppColors.primaryBlue100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '할인과 적립 중 뭐가 더 좋으세요?',
            style: AppTypography.h3,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '선호 혜택을 선택하면 카드 추천이 더 정확해져요.',
            style: AppTypography.body2,
          ),
          SizedBox(height: AppSpacing.md),
          AppComponents.primaryButton(
            text: '선호 혜택 설정하기',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BenefitManageScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRecommendationBanner() {
    if (_locationPermissionDenied) {
      return AppComponents.card(
        child: Column(
          children: [
            Text(
              '위치 권한이 필요해요',
              style: AppTypography.h3,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '근처에서 받을 수 있는 혜택을 알려드리려면 위치 접근을 허용해주세요.',
              style: AppTypography.body2,
            ),
            SizedBox(height: AppSpacing.md),
            AppComponents.primaryButton(
              text: '설정에서 권한 열기',
              onPressed: () {
                openAppSettings();
              },
            ),
          ],
        ),
      );
    }

    if (_currentRecommendation == null) {
      return AppComponents.card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '지금 어디에 계신가요?',
              style: AppTypography.h3,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '위치를 확인하면 최적의 카드를 추천해드려요.',
              style: AppTypography.body2,
            ),
            SizedBox(height: AppSpacing.md),
            AppComponents.primaryButton(
              text: '위치 기반 추천 받기',
              onPressed: _getLocationRecommendation,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlueDark, AppColors.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '지금 ${_currentRecommendation!.merchantName} 근처에 계신가요?',
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '${_currentRecommendation!.cardName} 카드로 결제 시 ${_currentRecommendation!.benefitDescription}',
            style: AppTypography.body2.copyWith(color: Colors.white70),
          ),
          SizedBox(height: AppSpacing.md),
          // 혜택 타입 탭
          Row(
            children: ['discount', 'points', 'cashback', 'mileage'].map((type) {
              final labels = {
                'discount': '할인',
                'points': '적립',
                'cashback': '캐시백',
                'mileage': '마일리지',
              };
              final isSelected = _selectedBenefitType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBenefitType = type;
                    });
                    _getLocationRecommendation();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      labels[type]!,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPerformanceSlider() {
    // 로딩 중일 때 스켈레톤 표시
    if (_isLoading) {
      return _buildShimmerCard();
    }

    if (_userCards.isEmpty) {
      return _buildCardPerformanceCard();
    }

    // 실적 데이터가 있는 카드만 필터링
    final cardsWithPerformance = _userCards.where((uc) {
      final perf = _cardPerformances[uc.cardId];
      return perf != null && perf.summary.currentSpending > 0;
    }).toList();

    if (cardsWithPerformance.isEmpty) {
      return AppComponents.emptyState(
        emoji: '💳',
        title: '아직 이번 달 거래 내역이 없어요',
        description: '카드를 사용하면 실적 정보가 표시됩니다.',
      ).animate().fadeIn(duration: 500.ms);
    }

    return Column(
      children: [
        // 카드 개수 표시
        if (cardsWithPerformance.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentCardPage + 1} / ${cardsWithPerformance.length}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        
        // 카드 슬라이더
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _cardPageController,
            itemCount: cardsWithPerformance.length,
            onPageChanged: (index) {
              setState(() {
                _currentCardPage = index;
              });
            },
            itemBuilder: (context, index) {
              final userCard = cardsWithPerformance[index];
              final performance = _cardPerformances[userCard.cardId];
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _buildCardPerformanceBox(userCard, performance),
              );
            },
          ),
        ),
        
        // 페이지 인디케이터 (점)
        if (cardsWithPerformance.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                cardsWithPerformance.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentCardPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentCardPage == index
                        ? AppColors.primaryBlue
                        : AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Shimmer 카드 로딩 위젯
  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPerformanceBox(UserCard userCard, PerformanceResponse? performance) {
    final card = userCard.card;
    if (card == null) return const SizedBox.shrink();

    // 현재 티어 정보 계산
    String tierInfo = '';
    if (performance != null && performance.summary.tiers.isNotEmpty) {
      final currentTierIndex = performance.summary.currentTier != null
          ? performance.summary.tiers.indexWhere((t) => t.code == performance.summary.currentTier)
          : 0;
      final targetAmount = performance.summary.tiers.last.minAmount;
      tierInfo = '${currentTierIndex + 1}구간 / ${NumberFormat('#,###').format(targetAmount)}원';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
        border: Border.all(
          color: AppColors.grey100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단: 카드 이름 + 카드 아이콘
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card.name,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                width: 56,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                  child: Image.asset(
                    '카드.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.md),
          
          // 실적 달성까지
          if (performance != null) ...[
            Text(
              '실적 달성까지',
              style: AppTypography.body2,
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${NumberFormat('#,###').format(performance.summary.remainingAmount)}원 남았어요',
                  style: AppTypography.t4.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (tierInfo.isNotEmpty)
                  Text(
                    tierInfo,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: AppSpacing.sm),
            
            // 프로그래스바
            _buildMiniProgressBar(performance.summary),
            
            SizedBox(height: AppSpacing.sm),
            
            // 채운 실적
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '채운 실적 ${NumberFormat('#,###').format(performance.summary.currentSpending)}원',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // 하단 CTA - 실적 달성하면 받는 혜택 보기
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardPerformanceScreen(cardId: card.id),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.badgeOrange,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 16)),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '실적 달성하면 받는 혜택 보기',
                        style: AppTypography.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
      .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut)
      .scale(begin: const Offset(0.95, 0.95), duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildMiniProgressBar(PerformanceSummary summary) {
    if (summary.tiers.isEmpty) {
      return const SizedBox.shrink();
    }

    // 전체 목표 금액 (마지막 티어의 minAmount)
    final totalAmount = summary.tiers.last.minAmount;
    final currentAmount = summary.currentSpending;
    
    // 전체 진행률 계산 (0.0 ~ 1.0)
    double overallProgress = totalAmount > 0 ? (currentAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 프로그래스 바
        Stack(
          children: [
            // 배경 바
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            // 진행 바
            FractionallySizedBox(
              widthFactor: overallProgress,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.success,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMissedBenefitsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MissedBenefitModal(missedBenefits: _missedBenefits),
    );
  }
}
