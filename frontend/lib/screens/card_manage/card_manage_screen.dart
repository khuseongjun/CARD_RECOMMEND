import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/components.dart';
import '../../theme/spacing.dart';
import '../../services/card_service.dart';
import '../../services/recommendation_service.dart';
import '../../models/user_card.dart';
import '../../models/card_product.dart';
import '../../models/recommendation.dart';
import 'package:intl/intl.dart';
import '../card_performance/card_performance_screen.dart';
import '../profile/profile_screen.dart';
import 'add_card_modal.dart';
import '../home/missed_benefit_modal.dart';

class CardManageScreen extends StatefulWidget {
  const CardManageScreen({super.key});

  @override
  State<CardManageScreen> createState() => _CardManageScreenState();
}

class _CardManageScreenState extends State<CardManageScreen> {
  final CardService _cardService = CardService();
  final RecommendationService _recommendationService = RecommendationService();
  
  List<UserCard> _userCards = [];
  bool _isDeleteMode = false;
  bool _isLoading = false;
  List<MissedBenefit> _missedBenefits = [];

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
      _userCards = await _cardService.getUserCards(userId);
      _missedBenefits = await _recommendationService.getMissedBenefits(userId);
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
                  color: AppColors.primaryBlue,
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
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('내 카드', style: AppTypography.t3),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isDeleteMode = !_isDeleteMode;
                              });
                            },
                            child: Text(
                              _isDeleteMode ? '완료' : '삭제',
                              style: AppTypography.body1.copyWith(
                                color: _isDeleteMode
                                    ? AppColors.primaryBlue
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _showAddCardModal();
                            },
                            child: Text(
                              '+ 카드 추가',
                              style: AppTypography.body1.copyWith(
                                color: AppColors.primaryBlue500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 카드 리스트
                Expanded(
                  child: _userCards.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card_off,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '등록된 카드가 없습니다',
                                style: AppTypography.body1.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _userCards.length,
                          itemBuilder: (context, index) {
                            final userCard = _userCards[index];
                            return _buildCardItem(userCard);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCardItem(UserCard userCard) {
    final card = userCard.card;
    if (card == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _isDeleteMode
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardPerformanceScreen(cardId: card.id),
                ),
              );
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            AppComponents.card(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카드 이미지
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.asset(
                            '카드.png',
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.screenPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                card.name,
                                style: AppTypography.h3.copyWith(color: Colors.white),
                              ),
                              Text(
                                card.issuer,
                                style: AppTypography.body2.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${card.issuer} ${card.name}',
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '국내전용 ${NumberFormat('#,###').format(card.annualFeeDomestic)}원 / MASTER ${NumberFormat('#,###').format(card.annualFeeInternational)}원',
                          style: AppTypography.body2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '전월실적 최소 ${NumberFormat('#,###').format(card.minMonthlySpending)}원',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isDeleteMode)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _deleteCard(userCard),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _deleteCard(UserCard userCard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 삭제'),
        content: Text('${userCard.card?.name} 카드를 내 카드에서 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                const userId = 'user_123';
                await _cardService.deleteUserCard(userId, userCard.cardId);
                _loadData();
                setState(() {
                  _isDeleteMode = false;
                });
              } catch (e) {
                // 에러 처리
              }
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCardModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddCardModal(
        onCardAdded: () {
          _loadData();
        },
      ),
    );
  }
}
