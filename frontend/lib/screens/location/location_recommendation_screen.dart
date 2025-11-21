import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/components.dart';
import '../card_detail/card_detail_screen.dart';

/// 위치 기반 카드 추천 화면
class LocationRecommendationScreen extends StatefulWidget {
  const LocationRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<LocationRecommendationScreen> createState() => _LocationRecommendationScreenState();
}

class _LocationRecommendationScreenState extends State<LocationRecommendationScreen> {
  bool _isLoading = true;
  
  // 하드코딩된 추천 데이터
  final List<Map<String, dynamic>> _recommendations = [
    {
      'merchant': '스타벅스 강남역점',
      'category': '카페',
      'emoji': '☕️',
      'distance': 120,
      'cardName': 'KB국민 MR.Life',
      'cardEmoji': '💳',
      'benefit': '15% 할인',
      'benefitDetail': '월 최대 5,000원',
      'bgColor': AppColors.badgeTeal,
      'accentColor': AppColors.accentTeal,
    },
    {
      'merchant': '메가커피 테헤란로점',
      'category': '카페',
      'emoji': '☕️',
      'distance': 85,
      'cardName': '신한카드 Deep Dream',
      'cardEmoji': '💳',
      'benefit': '1,000원 할인',
      'benefitDetail': '월 3회',
      'bgColor': AppColors.badgeBlue,
      'accentColor': AppColors.accentBlue,
    },
    {
      'merchant': 'CGV 강남',
      'category': '영화',
      'emoji': '🎬',
      'distance': 250,
      'cardName': 'KB국민 MR.Life',
      'cardEmoji': '💳',
      'benefit': '영화 8,000원',
      'benefitDetail': '월 2회',
      'bgColor': AppColors.badgePurple,
      'accentColor': AppColors.accentPurple,
    },
    {
      'merchant': 'GS25 역삼점',
      'category': '편의점',
      'emoji': '🏪',
      'distance': 50,
      'cardName': '토스 체크카드',
      'cardEmoji': '💳',
      'benefit': '2% 적립',
      'benefitDetail': '한도 없음',
      'bgColor': AppColors.badgeOrange,
      'accentColor': AppColors.accentOrange,
    },
    {
      'merchant': '올리브영 강남중앙점',
      'category': '뷰티',
      'emoji': '💄',
      'distance': 180,
      'cardName': '신한카드 Deep Dream',
      'cardEmoji': '💳',
      'benefit': '10% 할인',
      'benefitDetail': '월 최대 3,000원',
      'bgColor': AppColors.badgePink,
      'accentColor': AppColors.accentPink,
    },
    {
      'merchant': '맥도날드 강남역점',
      'category': '외식',
      'emoji': '🍔',
      'distance': 140,
      'cardName': 'KB국민 MR.Life',
      'cardEmoji': '💳',
      'benefit': '20% 할인',
      'benefitDetail': '월 최대 7,000원',
      'bgColor': AppColors.badgeRed,
      'accentColor': AppColors.error,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 로딩 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '주변 혜택',
          style: AppTypography.t4,
        ),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoadingSkeleton() : _buildContent(),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppComponents.cardSkeleton(),
        );
      },
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // 헤더 섹션
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 현재 위치
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '강남역 10번 출구',
                              style: AppTypography.t4,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '서울특별시 강남구 역삼동',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0, duration: 400.ms),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // 제목
                  Text(
                    '내 카드로 혜택받을 수 있는\n주변 가맹점이에요',
                    style: AppTypography.t3,
                  ).animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, delay: 100.ms, duration: 400.ms),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // 추천 개수
                  Row(
                    children: [
                      Text(
                        '총 ',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_recommendations.length}곳',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '의 혜택을 찾았어요',
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ).animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
          
          // 추천 리스트
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _recommendations[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildRecommendationCard(item, index),
                  );
                },
                childCount: _recommendations.length,
              ),
            ),
          ),
          
          // 하단 여백
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xl),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        // 카드 상세 화면으로 이동 (하드코딩된 카드 ID 사용)
        String cardId = 'kb_mr_life'; // 기본값
        if (item['cardName'].contains('신한')) {
          cardId = 'shinhan_deep_dream';
        } else if (item['cardName'].contains('토스')) {
          cardId = 'toss_check';
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailScreen(cardId: cardId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.grey100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 가맹점 로고
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item['bgColor'],
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      item['emoji'],
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppSpacing.md),
                
                // 가맹점 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['merchant'],
                              style: AppTypography.body1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${item['distance']}m',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        item['category'],
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 구분선
            Container(
              height: 1,
              color: AppColors.divider,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // 혜택 정보
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: item['bgColor'],
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  // 카드 이모지
                  Text(
                    item['cardEmoji'],
                    style: const TextStyle(fontSize: 24),
                  ),
                  
                  const SizedBox(width: AppSpacing.sm),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['cardName'],
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              item['benefit'],
                              style: AppTypography.body1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: item['accentColor'],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item['benefitDetail'],
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 화살표
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate()
        .fadeIn(delay: (300 + index * 50).ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0, delay: (300 + index * 50).ms, duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), delay: (300 + index * 50).ms, duration: 400.ms),
    );
  }
}

