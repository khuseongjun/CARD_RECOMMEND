/// 카드 목록 화면 (카드 추가용)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
import '../providers/card_provider.dart';
import '../widgets/card_item_widget.dart';
import 'card_detail_screen.dart';

class CardListScreen extends ConsumerWidget {
  const CardListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);
    final cardRegistrationAsync = ref.watch(cardRegistrationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('카드 추가'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: cardsAsync.when(
        data: (cards) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return CardItemWidget(
                card: card,
                onTap: () async {
                  // 카드 등록
                  await ref
                      .read(cardRegistrationProvider.notifier)
                      .registerCard(card.cardId);

                  if (!context.mounted) return;

                  cardRegistrationAsync.when(
                    data: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${card.name} 카드가 등록되었습니다'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    loading: () {},
                    error: (error, stack) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString()),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                  );
                },
              );
            },
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
                '카드 목록을 불러올 수 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

