import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/card_service.dart';
import '../../models/card_product.dart';
import 'package:intl/intl.dart';

class AddCardModal extends StatefulWidget {
  final VoidCallback onCardAdded;

  const AddCardModal({super.key, required this.onCardAdded});

  @override
  State<AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal> {
  final CardService _cardService = CardService();
  final TextEditingController _searchController = TextEditingController();
  List<CardProduct> _cards = [];
  List<CardProduct> _filteredCards = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
    _searchController.addListener(_filterCards);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _cards = await _cardService.searchCards();
      _filteredCards = _cards;
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCards() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCards = _cards;
      } else {
        _filteredCards = _cards.where((card) {
          return card.name.toLowerCase().contains(query) ||
              card.issuer.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('카드 추가', style: AppTypography.h2),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 검색창
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '카드명이나 발급사로 검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // 카드 리스트
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCards.isEmpty
                      ? Center(
                          child: Text(
                            '검색 결과가 없습니다',
                            style: AppTypography.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _filteredCards.length,
                          itemBuilder: (context, index) {
                            final card = _filteredCards[index];
                            return _buildCardItem(card);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(CardProduct card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // 카드사 이니셜 뱃지
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                card.issuer.substring(0, 1),
                style: AppTypography.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 카드 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${card.issuer} + 국내전용 ${NumberFormat('#,###').format(card.annualFeeDomestic)}원 / MASTER ${NumberFormat('#,###').format(card.annualFeeInternational)}원',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          // 추가 버튼
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primaryBlue,
            onPressed: () async {
              try {
                const userId = 'user_123';
                await _cardService.addUserCard(userId, card.id);
                widget.onCardAdded();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('내 카드에 추가했어요.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('에러: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

