import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/benefit_service.dart';
import '../../services/user_service.dart';
import '../../services/recommendation_service.dart';
import '../../models/user.dart';
import '../../models/recommendation.dart';
import 'benefit_preference_widget.dart';
import '../profile/profile_screen.dart';
import '../home/missed_benefit_modal.dart';

class BenefitManageScreen extends StatefulWidget {
  const BenefitManageScreen({super.key});

  @override
  State<BenefitManageScreen> createState() => _BenefitManageScreenState();
}

class _BenefitManageScreenState extends State<BenefitManageScreen>
    with SingleTickerProviderStateMixin {
  final BenefitService _benefitService = BenefitService();
  final UserService _userService = UserService();
  final RecommendationService _recommendationService = RecommendationService();
  
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  User? _user;
  Map<String, dynamic>? _benefitSummary;
  Map<String, dynamic>? _benefitRank;
  List<MissedBenefit> _missedBenefits = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      const userId = 'user_123';
      final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);
      
      _user = await _userService.getUser(userId);
      _benefitSummary = await _benefitService.getBenefitSummary(userId, monthStr);
      _benefitRank = await _benefitService.getBenefitRank(userId);
      _missedBenefits = await _recommendationService.getMissedBenefits(userId);
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (_missedBenefits.isNotEmpty) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => MissedBenefitModal(missedBenefits: _missedBenefits),
                  );
                }
              },
              child: Text(
                '놓친혜택 ${_missedBenefits.length}건 >',
                style: AppTypography.body2.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue700,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: '받은 혜택'),
            Tab(text: '내 혜택 순위'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedBenefitsTab(),
          _buildRankTab(),
        ],
      ),
    );
  }

  Widget _buildReceivedBenefitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선호 혜택 선택
          BenefitPreferenceWidget(
            user: _user,
            onUpdated: () {
              _loadData();
            },
          ),

          const SizedBox(height: 24),

          // 월 선택
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                DateFormat('yyyy년 M월').format(_selectedMonth),
                style: AppTypography.h3,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 요약 카드
          AppComponents.card(
            backgroundColor: AppColors.primaryBlueLight,
            child: Column(
              children: [
                const Text('💰', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  '이번 달 받은 혜택',
                  style: AppTypography.body2,
                ),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat('#,###').format(_benefitSummary?['total_benefit'] ?? 0)}원',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '모든 카드에서 받은 혜택의 합계예요.\n(연회비, 기프트카드 제외)',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 카드별 혜택 리스트
          Text('카드별 혜택', style: AppTypography.h3),
          const SizedBox(height: 12),
          if (_benefitSummary?['card_benefits'] != null)
            ...(_benefitSummary!['card_benefits'] as List).map((cardBenefit) {
              return AppComponents.card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.credit_card),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cardBenefit['card_name'] ?? '',
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '이달 혜택 ${NumberFormat('#,###').format(cardBenefit['benefit_amount'] ?? 0)}원',
                            style: AppTypography.body2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildRankTab() {
    if (_benefitRank == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final percentile = _benefitRank!['percentile'] ?? 0.0;
    final totalSpending = _benefitRank!['total_spending_1y'] ?? 0;
    final totalBenefit = _benefitRank!['total_benefit_1y'] ?? 0;
    final discountRate = _benefitRank!['discount_rate'] ?? 0.0;
    final avgDiscountRate = _benefitRank!['average_discount_rate'] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 텍스트
          Text(
            '받은한달 카드 혜택은',
            style: AppTypography.body1,
          ),
          SizedBox(height: AppSpacing.xs),
          
          // 메인 타이틀
          RichText(
            text: TextSpan(
              style: AppTypography.t2.copyWith(
                color: AppColors.textPrimary,
              ),
              children: [
                const TextSpan(text: '백색 고객 중 '),
                TextSpan(
                  text: '상위 ${percentile.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: '에요'),
              ],
            ),
          ),
          
          SizedBox(height: AppSpacing.xs),
          
          // 부제
          Text(
            '피킹률은 순위를 계산했어요',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          SizedBox(height: AppSpacing.xl),
          
          // 삼각형 차트
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(200, 150),
                  painter: TrianglePainter(color: AppColors.success),
                ),
                Positioned(
                  bottom: 10,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '상위 ${percentile.toStringAsFixed(2)}%',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSpacing.xl),
          
          // 통계 리스트
          _buildStatItem(
            icon: '🏆',
            title: '최근 1년 카드 소비',
            value: '${NumberFormat('#,###').format(totalSpending)}원',
          ),
          
          SizedBox(height: AppSpacing.md),
          
          _buildStatItem(
            icon: '🟠',
            title: '받은 혜택',
            value: '${NumberFormat('#,###').format(totalBenefit)}원',
          ),
          
          SizedBox(height: AppSpacing.md),
          
          _buildStatItem(
            icon: '💚',
            title: '실시용 견적비',
            value: '${totalBenefit > 0 ? "-" : ""}${NumberFormat('#,###').format(totalBenefit)}원',
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // 하단 안내 텍스트
          Text(
            '*실시용 견적비는 카드를 모든 사용자 기준 금액과 객관적 연회비예요.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.body1,
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.body1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// 삼각형 그리기 위한 CustomPainter
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // 상단 중앙
    path.lineTo(0, size.height); // 왼쪽 하단
    path.lineTo(size.width, size.height); // 오른쪽 하단
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
