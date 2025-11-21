import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/performance_service.dart';
import '../../services/card_service.dart';
import '../../models/performance.dart';
import '../../models/card_product.dart';
import '../card_detail/card_detail_screen.dart';

class CardPerformanceScreen extends StatefulWidget {
  final String cardId;

  const CardPerformanceScreen({super.key, required this.cardId});

  @override
  State<CardPerformanceScreen> createState() => _CardPerformanceScreenState();
}

class _CardPerformanceScreenState extends State<CardPerformanceScreen> {
  final PerformanceService _performanceService = PerformanceService();
  final CardService _cardService = CardService();
  
  DateTime _selectedMonth = DateTime.now();
  PerformanceResponse? _performance;
  CardProduct? _card;
  bool _isLoading = false;
  int _selectedTab = 0; // 0: 실적 인정, 1: 실적 제외

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
      final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);
      
      _card = await _cardService.getCardDetails(widget.cardId);
      _performance = await _performanceService.getCardPerformance(
        userId,
        widget.cardId,
        monthStr,
      );
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
        title: Text(_card?.name ?? '카드 실적', style: AppTypography.t3),
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : _performance == null
              ? AppComponents.emptyState(
                  emoji: '📊',
                  title: '데이터를 불러올 수 없습니다',
                  description: '잠시 후 다시 시도해주세요',
                  buttonText: '다시 시도',
                  onButtonPressed: _loadData,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 월 선택
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _changeMonth(-1),
                            ),
                            Text(
                              DateFormat('M월').format(_selectedMonth),
                              style: AppTypography.t3,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 실적 요약 카드
                      _buildSummaryCard(_performance!),
                      const SizedBox(height: 16),

                      // 실적 달성하면 받는 혜택 보기
                      _buildBenefitButton(),
                      const SizedBox(height: 24),

                      // 탭바
                      _buildTabBar(),
                      const SizedBox(height: 16),

                      // 거래 리스트
                      _buildTransactionList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard(PerformanceResponse performance) {
    final summary = performance.summary;
    return AppComponents.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '실적 달성까지 ${NumberFormat('#,###').format(summary.remainingAmount)}원 남았어요',
                      style: AppTypography.t3.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '채운 실적 ${NumberFormat('#,###').format(summary.currentSpending)}원',
                      style: AppTypography.t6,
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLight,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.credit_card, color: AppColors.primaryBlue, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 티어 프로그래스바
          _buildTierProgressBar(summary),
        ],
      ),
    );
  }

  Widget _buildTierProgressBar(PerformanceSummary summary) {
    if (summary.tiers.isEmpty) {
      return const SizedBox.shrink();
    }

    // 현재 구간 인덱스 찾기
    int currentTierIndex = 0;
    if (summary.currentTier != null) {
      currentTierIndex = summary.tiers.indexWhere((t) => t.code == summary.currentTier);
      if (currentTierIndex == -1) currentTierIndex = 0;
    }

    // 전체 목표 금액 (마지막 티어의 minAmount)
    final totalAmount = summary.tiers.last.minAmount;
    final currentAmount = summary.currentSpending;
    
    // 전체 진행률 계산 (0.0 ~ 1.0)
    double overallProgress = totalAmount > 0 ? (currentAmount / totalAmount).clamp(0.0, 1.0) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 티어 라벨들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: summary.tiers.asMap().entries.map((entry) {
            final tier = entry.value;
            return Expanded(
              child: Text(
                tier.label,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 8),
        
        // 프로그래스 바
        Stack(
          children: [
            // 배경 바
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            // 진행 바
            FractionallySizedBox(
              widthFactor: overallProgress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.success,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            
            // 구간 구분선들
            ...summary.tiers.asMap().entries.map((entry) {
              final index = entry.key;
              if (index == 0) return const SizedBox.shrink();
              
              final tier = entry.value;
              final position = tier.minAmount / totalAmount;
              
              return Positioned(
                left: position * MediaQuery.of(context).size.width * 0.85 - 1,
                child: Container(
                  width: 2,
                  height: 8,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 금액 라벨들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: summary.tiers.asMap().entries.map((entry) {
            final tier = entry.value;
            return Expanded(
              child: Text(
                '${NumberFormat('#,###').format(tier.minAmount ~/ 10000)}만',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 12),
        
        // 현재 상태 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '현재 ${summary.tiers[currentTierIndex].label}',
              style: AppTypography.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
            Text(
              '${(overallProgress * 100).toStringAsFixed(1)}%',
              style: AppTypography.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBenefitButton() {
    return AppComponents.card(
      backgroundColor: AppColors.primaryBlueLight,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailScreen(cardId: widget.cardId),
            ),
          );
        },
        child: Row(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 32)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '실적 달성하면 받는 혜택 보기',
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '이 카드로 받을 수 있는 혜택을 한 눈에 볼 수 있어요.',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              '실적 인정',
              0,
              _performance?.recognized.length ?? 0,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              '실적 제외',
              1,
              _performance?.excluded.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, int count) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.body1.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$count건',
              style: AppTypography.caption.copyWith(
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_performance == null) return const SizedBox.shrink();
    
    final transactions = _selectedTab == 0
        ? _performance!.recognized
        : _performance!.excluded;

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                _selectedTab == 0 ? '실적 인정 내역이 없습니다' : '실적 제외 내역이 없습니다',
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '카드를 사용하면 거래 내역이 표시됩니다.',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 날짜별 그룹화
    final grouped = <String, List<TransactionWithClassification>>{};
    for (final tx in transactions) {
      final dateKey = DateFormat('M월 d일 EEEE', 'ko').format(tx.approvedAt);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                entry.key,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...entry.value.map((tx) => _buildTransactionItem(tx)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTransactionItem(TransactionWithClassification tx) {
    final timeStr = DateFormat('HH:mm').format(tx.approvedAt);
    
    return AppComponents.card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 인디케이터
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: AppColors.primaryBlue,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tx.merchantName,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  timeStr,
                  style: AppTypography.caption,
                ),
                if (tx.reason != null && _selectedTab == 1) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    tx.reason!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${NumberFormat('#,###').format(tx.amount)}원',
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '실적 반영 ${NumberFormat('#,###').format(tx.performanceAmount)}원',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: 0.05, end: 0, duration: 400.ms);
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Shimmer.fromColors(
        baseColor: AppColors.grey200,
        highlightColor: AppColors.grey100,
        child: Column(
          children: [
            // 월 선택기 스켈레톤
            Container(
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            const SizedBox(height: 24),
            
            // 요약 카드 스켈레톤
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            const SizedBox(height: 16),
            
            // 프로그래스 바 스켈레톤
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            const SizedBox(height: 24),
            
            // 거래 목록 스켈레톤
            ...List.generate(5, (index) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              width: double.infinity,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
