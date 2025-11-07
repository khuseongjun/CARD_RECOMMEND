/// 카드 상세 화면 (TDS 디자인 시스템 적용)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flip_card/flip_card.dart';
import '../config/app_colors.dart';
import '../providers/card_provider.dart';
import '../models/card_model.dart';
import '../widgets/app_badge.dart';

class CardDetailScreen extends ConsumerStatefulWidget {
  final int cardId;

  const CardDetailScreen({
    Key? key,
    required this.cardId,
  }) : super(key: key);

  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends ConsumerState<CardDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'priority'; // priority, discount, limit

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardDetailAsync = ref.watch(cardDetailProvider(widget.cardId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: cardDetailAsync.when(
        data: (card) {
          return CustomScrollView(
            slivers: [
              // 앱바 + 카드 이미지
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                          child: _buildFlipCard(card),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 카드 정보 섹션
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카드명과 발급사
                      Text(
                        card.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.issuer,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 카드 정보 박스
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '카드 정보',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),

                            if (card.annualFeeText != null) ...[
                              _InfoRow(
                                label: '연회비',
                                value: card.annualFeeText!,
                              ),
                              const SizedBox(height: 12),
                            ],

                            if (card.minSpendText != null) ...[
                              _InfoRow(
                                label: '전월실적',
                                value: card.minSpendText!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 혜택 섹션 헤더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '전체 혜택',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (card.benefits != null)
                            AppBadge(
                              text: '${card.benefits!.length}개',
                              type: BadgeType.blue,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 검색바
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '혜택명, 가맹점으로 검색',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.divider),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 필터 및 정렬
                      Row(
                        children: [
                          // 카테고리 필터
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterChip(
                                    label: '전체',
                                    isSelected: _selectedCategory == null,
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = null;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: '커피',
                                    isSelected: _selectedCategory == '커피',
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = '커피';
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: '대중교통',
                                    isSelected: _selectedCategory == '대중교통',
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = '대중교통';
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterChip(
                                    label: '편의점',
                                    isSelected: _selectedCategory == '편의점',
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = '편의점';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 정렬
                          PopupMenuButton<String>(
                            initialValue: _sortBy,
                            onSelected: (value) {
                              setState(() {
                                _sortBy = value;
                              });
                            },
                            icon: const Icon(Icons.sort),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'priority',
                                child: Text('추천순'),
                              ),
                              const PopupMenuItem(
                                value: 'discount',
                                child: Text('할인율↓'),
                              ),
                              const PopupMenuItem(
                                value: 'limit',
                                child: Text('한도↑'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 혜택 리스트
              if (card.benefits != null && card.benefits!.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: _buildBenefitsList(card.benefits!),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildEmptyState(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                '카드 정보를 불러올 수 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlipCard(CardModel card) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      speed: 300,
      front: _buildCardFront(card),
      back: _buildCardBack(card),
    );
  }

  Widget _buildCardFront(CardModel card) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.issuer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              card.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '탭하여 뒷면 보기',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(CardModel card) {
    // 대표 혜택 아이콘 (최대 6개)
    final topBenefits = card.benefits?.take(6).toList() ?? [];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '주요 혜택',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: topBenefits.isEmpty
                  ? const Center(
                      child: Text(
                        '등록된 혜택이 없습니다',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: topBenefits.map((benefit) {
                        return Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _getCategoryEmoji(benefit.title),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('커피') || lowerTitle.contains('카페')) return '☕';
    if (lowerTitle.contains('대중교통') || lowerTitle.contains('버스') || lowerTitle.contains('지하철')) return '🚌';
    if (lowerTitle.contains('편의점')) return '🏪';
    if (lowerTitle.contains('영화')) return '🎬';
    if (lowerTitle.contains('쇼핑')) return '🛍️';
    if (lowerTitle.contains('여행')) return '✈️';
    if (lowerTitle.contains('주유')) return '⛽';
    if (lowerTitle.contains('통신')) return '📱';
    if (lowerTitle.contains('구독')) return '📺';
    return '💳';
  }

  Widget _buildBenefitsList(List<BenefitModel> benefits) {
    // 필터링
    var filteredBenefits = benefits.where((benefit) {
      // 검색 필터
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = benefit.title.toLowerCase().contains(_searchQuery) ||
            (benefit.shortDesc?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // 카테고리 필터
      if (_selectedCategory != null) {
        final matchesCategory = benefit.title.contains(_selectedCategory!);
        if (!matchesCategory) return false;
      }

      return true;
    }).toList();

    // 정렬
    if (_sortBy == 'discount') {
      filteredBenefits.sort((a, b) {
        final aDiscount = a.ratePct ?? 0;
        final bDiscount = b.ratePct ?? 0;
        return bDiscount.compareTo(aDiscount);
      });
    } else if (_sortBy == 'limit') {
      filteredBenefits.sort((a, b) {
        final aLimit = a.perMonth ?? 0;
        final bLimit = b.perMonth ?? 0;
        return bLimit.compareTo(aLimit);
      });
    } else {
      filteredBenefits.sort((a, b) => a.priority.compareTo(b.priority));
    }

    if (filteredBenefits.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final benefit = filteredBenefits[index];
          return _BenefitCard(benefit: benefit);
        },
        childCount: filteredBenefits.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            '선택한 필터에 해당하는 혜택이 없어요',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '필터를 해제해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// 정보 행
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// 필터 칩
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// 혜택 카드 (Accordion)
class _BenefitCard extends StatefulWidget {
  final BenefitModel benefit;

  const _BenefitCard({required this.benefit});

  @override
  State<_BenefitCard> createState() => _BenefitCardState();
}

class _BenefitCardState extends State<_BenefitCard> {
  bool _isExpanded = false;

  Color get _categoryColor {
    final title = widget.benefit.title.toLowerCase();
    if (title.contains('커피') || title.contains('카페')) {
      return AppColors.benefitCoffee;
    } else if (title.contains('대중교통') || title.contains('버스') || title.contains('지하철')) {
      return AppColors.benefitTransport;
    } else if (title.contains('편의점')) {
      return AppColors.benefitConvenience;
    } else if (title.contains('영화')) {
      return AppColors.benefitMovie;
    } else if (title.contains('쇼핑')) {
      return AppColors.benefitShopping;
    } else if (title.contains('여행')) {
      return AppColors.benefitTravel;
    } else if (title.contains('주유')) {
      return AppColors.benefitGas;
    } else if (title.contains('통신')) {
      return AppColors.benefitTelecom;
    } else if (title.contains('구독')) {
      return AppColors.benefitSubscription;
    } else {
      return AppColors.primary;
    }
  }

  String get _categoryEmoji {
    final title = widget.benefit.title.toLowerCase();
    if (title.contains('커피') || title.contains('카페')) return '☕';
    if (title.contains('대중교통') || title.contains('버스') || title.contains('지하철')) return '🚌';
    if (title.contains('편의점')) return '🏪';
    if (title.contains('영화')) return '🎬';
    if (title.contains('쇼핑')) return '🛍️';
    if (title.contains('여행')) return '✈️';
    if (title.contains('주유')) return '⛽';
    if (title.contains('통신')) return '📱';
    if (title.contains('구독')) return '📺';
    return '💳';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // 메인 정보
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 아이콘
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _categoryEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 혜택 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.benefit.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (widget.benefit.shortDesc != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.benefit.shortDesc!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 할인율 배지
                  Column(
                    children: [
                      if (widget.benefit.ratePct != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${widget.benefit.ratePct!.toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        )
                      else if (widget.benefit.flatAmount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${widget.benefit.flatAmount}원',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 상세 정보 (펼쳐짐)
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // 상세 정보 표
                  _DetailRow(label: '혜택 유형', value: widget.benefit.benefitType ?? '-'),
                  const SizedBox(height: 8),
                  if (widget.benefit.perTxnAmountCap != null)
                    _DetailRow(
                      label: '1회 한도',
                      value: '${widget.benefit.perTxnAmountCap}원',
                    ),
                  if (widget.benefit.perMonth != null) ...[
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: '월 한도',
                      value: '${widget.benefit.perMonth}원',
                    ),
                  ],
                  if (widget.benefit.perDay != null) ...[
                    const SizedBox(height: 8),
                    _DetailRow(
                      label: '일 한도',
                      value: '${widget.benefit.perDay}회',
                    ),
                  ],

                  // 적용 범위
                  if (widget.benefit.scopes != null && widget.benefit.scopes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '적용 대상',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.benefit.scopes!.map((scope) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scope.include ? '• ' : '✗ ',
                              style: TextStyle(
                                color: scope.include ? AppColors.success : AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${scope.scopeType}: ${scope.scopeValue}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  // 시간대 제한
                  if (widget.benefit.timeWindows != null && widget.benefit.timeWindows!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      '적용 시간',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.benefit.timeWindows!.map((window) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${window.startTime} ~ ${window.endTime}${window.daysOfWeek != null ? ' (${window.daysOfWeek})' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// 상세 정보 행
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
