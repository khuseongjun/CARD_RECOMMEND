/// 카드 상태 관리 Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// 카드 목록 프로바이더
final cardsProvider = FutureProvider<List<CardModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getCards();
});

// 카드 상세 정보 프로바이더
final cardDetailProvider =
    FutureProvider.family<CardModel, int>((ref, cardId) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getCardDetail(cardId);
});

// 사용자 등록 카드 목록 프로바이더
final userCardsProvider = FutureProvider<List<CardModel>>((ref) async {
  final authState = ref.watch(authProvider);
  
  if (!authState.isAuthenticated || authState.user == null) {
    return [];
  }

  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getUserCards(authState.user!.userId);
});

// 카드 등록 상태
class CardRegistrationNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CardRegistrationNotifier(this.ref) : super(const AsyncValue.data(null));

  /// 카드 등록
  Future<void> registerCard(int cardId) async {
    final authState = ref.read(authProvider);
    
    if (!authState.isAuthenticated || authState.user == null) {
      state = AsyncValue.error('로그인이 필요합니다', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.registerUserCard(authState.user!.userId, cardId);
      
      // 사용자 카드 목록 새로고침
      ref.invalidate(userCardsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// 카드 등록 프로바이더
final cardRegistrationProvider =
    StateNotifierProvider<CardRegistrationNotifier, AsyncValue<void>>((ref) {
  return CardRegistrationNotifier(ref);
});

// 카드 삭제 상태
class CardDeletionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CardDeletionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// 카드 삭제
  Future<void> deleteCard(int userId, int cardId) async {
    state = const AsyncValue.loading();

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.deleteUserCard(userId, cardId);
      
      // 사용자 카드 목록 새로고침
      ref.invalidate(userCardsProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}

// 카드 삭제 프로바이더
final cardDeletionProvider =
    StateNotifierProvider<CardDeletionNotifier, AsyncValue<void>>((ref) {
  return CardDeletionNotifier(ref);
});

