import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/card_service.dart';
import '../../models/card_product.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final CardService _cardService = CardService();
  CardProduct? _card;
  bool _isLoading = false;
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  Future<void> _loadCard() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      _card = await _cardService.getCardDetails(widget.cardId);
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _buildLoadingSkeleton(),
      );
    }

    if (_card == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: AppComponents.emptyState(
          emoji: '😢',
          title: '카드 정보를 불러올 수 없습니다',
          description: '잠시 후 다시 시도해주세요',
          buttonText: '다시 시도',
          onButtonPressed: _loadCard,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Hero 섹션
          SliverToBoxAdapter(
            child: _buildHeroSection(_card!),
          ),

          // 주요 혜택 + 전월실적
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: _buildMainBenefits(_card!),
            ),
          ),

          // 카테고리별 상세 혜택
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('혜택', style: AppTypography.t3),
                  SizedBox(height: AppSpacing.md),
                  _buildCategoryBenefits(),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(CardProduct card) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          // 카드 이미지
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: _card?.imageUrl != null && _card!.imageUrl!.isNotEmpty
                  ? Image.network(
                      'http://127.0.0.1:8000${_card!.imageUrl}',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.grey100, AppColors.grey200],
                            ),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.credit_card,
                              size: 64,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.credit_card,
                          size: 64,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
            ),
          ).animate()
            .fadeIn(duration: 500.ms, curve: Curves.easeOut)
            .scale(begin: const Offset(0.9, 0.9), duration: 500.ms, curve: Curves.easeOut),
          
          SizedBox(height: AppSpacing.lg),
          
          // 태그들
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              _buildTag(card.issuer),
              ...card.cardType.map((type) => _buildTag(type)),
              ...card.benefitTypes.map((type) => _buildTag(type)),
            ],
          ).animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),
          
          SizedBox(height: AppSpacing.md),
          
          // 카드 이름
          Text(
            card.name,
            style: AppTypography.t2,
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 400.ms),
          
          SizedBox(height: AppSpacing.sm),
          
          // 카드 설명
          Text(
            '꾸꾸고 즐기는 청춘을 위한 다양한 할인 혜택',
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMainBenefits(CardProduct card) {
    // 샘플 주요 혜택
    final mainBenefits = [
      {'emoji': '🚌', 'title': '대중교통 20%'},
      {'emoji': '☕', 'title': '스타벅스 20%'},
      {'emoji': '🎬', 'title': 'CGV 35%'},
      {'emoji': '🛍️', 'title': '쇼핑 5%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('주요 혜택', style: AppTypography.t4),
        SizedBox(height: AppSpacing.md),
        
        // 2x2 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.5,
          ),
          itemCount: mainBenefits.length,
          itemBuilder: (context, index) {
            final benefit = mainBenefits[index];
            return Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Text(benefit['emoji']!, style: const TextStyle(fontSize: 28)),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      benefit['title']!,
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        SizedBox(height: AppSpacing.xl),
        
        // 전월실적
        Text('전월실적', style: AppTypography.t4),
        SizedBox(height: AppSpacing.sm),
        Text(
          '최소 ${_formatNumber(card.minMonthlySpending)}원',
          style: AppTypography.body1,
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildCategoryBenefits() {
    // 샘플 카테고리별 혜택
    final categories = [
      {
        'emoji': '🚌',
        'title': '대중교통',
        'desc': '대중교통(전국 버스, 지하철) 20% 청구 할인',
        'rate': '20% 할인',
        'details': [
          '이용금액 월 5만원까지 할인 적용(최대 할인금액 1만원)',
          '대중교통 요금 할인은 실제 카드사용일이 아닌 이메일 이용내역서 상 기재된 이용일 기준으로 적용',
        ],
      },
      {
        'emoji': '☕',
        'title': '스타벅스',
        'desc': '스타벅스 20% 환급할인',
        'rate': '20% 할인',
        'details': [
          '건당 이용금액 1만원 이상 시, 건당 최대 이용금액 2만원까지 할인 적용(1회 최대 할인금액 4천원)',
          '상품권 구매 및 스타벅스카드 충전 시 할인 적용 제외',
          '백화점/대형마트 등에 입점된 일부 매장은 할인 적용에서 제외',
        ],
      },
      {
        'emoji': '🎬',
        'title': '영화',
        'desc': 'CGV 35% 환급할인',
        'rate': '35% 할인',
        'details': [
          '건당 이용금액 1만원 이상 시 건당 최대 이용금액 2만원까지 할인 적용(최대 할인액 7,000원)',
          '인터넷 예매 시 영화관 직영 홈페이지 www.cgv.co.kr 및 스마트폰 CGV 어플리케이션을 통해 결제한 경우만 할인 적용',
          '상품권 구매 및 매점 이용분은 제외',
        ],
      },
      {
        'emoji': '🛍️',
        'title': '쇼핑',
        'desc': 'GS홈쇼핑, CJ홈쇼핑, G마켓, 옥션 5% 환급할인',
        'rate': '5% 할인',
        'details': [
          '월 최대 1만원까지 할인 적용',
          '일부 매장 및 품목 제외',
        ],
      },
      {
        'emoji': '📚',
        'title': '서점',
        'desc': '교보문고 5% 할인',
        'rate': '5% 할인',
        'details': [
          '월 최대 5천원까지 할인 적용',
          '도서 및 문구류 구매 시',
        ],
      },
    ];

    return Column(
      children: categories.map<Widget>((category) {
        final title = category['title'] as String;
        final isExpanded = _expandedCategories[title] ?? false;
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        category['emoji'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  // 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          category['desc'] as String,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  // 혜택 비율
                  Text(
                    category['rate'] as String,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              // 자세히/접기 버튼
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedCategories[title] = !isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      isExpanded ? '접기 ^' : '자세히 v',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 펼침 내용
              if (isExpanded) ...[
                SizedBox(height: AppSpacing.md),
                ...( category['details'] as List<String>).map((detail) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                        Expanded(
                          child: Text(
                            detail,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Shimmer.fromColors(
        baseColor: AppColors.grey200,
        highlightColor: AppColors.grey100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 카드 이미지 스켈레톤
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // 태그 스켈레톤
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              )),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // 타이틀 스켈레톤
            Container(
              width: 200,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // 설명 스켈레톤
            Container(
              width: 250,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // 주요 혜택 스켈레톤
            ...List.generate(4, (index) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              width: double.infinity,
              height: 80,
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
