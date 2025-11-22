import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../theme/spacing.dart';
import '../../theme/components.dart';
import '../../services/location_service.dart';
import '../../services/place_service.dart';
import '../../services/recommend_service.dart';
import '../../models/place.dart';
import '../../models/recommend.dart';
import '../../models/user_card.dart';
import '../../services/card_service.dart';
import '../card_detail/card_detail_screen.dart';

/// 위치 기반 카드 추천 화면
class LocationRecommendationScreen extends StatefulWidget {
  const LocationRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<LocationRecommendationScreen> createState() => _LocationRecommendationScreenState();
}

class _LocationRecommendationScreenState extends State<LocationRecommendationScreen> {
  final LocationService _locationService = LocationService();
  final PlaceService _placeService = PlaceService();
  final RecommendService _recommendService = RecommendService();
  final CardService _cardService = CardService();
  
  bool _isLoading = true;
  bool _locationPermissionDenied = false;
  Position? _currentPosition;
  String _locationName = '위치 정보 없음';
  String _locationAddress = '';
  List<PlaceWithRecommendation> _placesWithRecommendations = [];
  List<UserCard> _userCards = [];
  
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
      
      // 사용자 카드 로드
      _userCards = await _cardService.getUserCards(userId);
      
      // 현재 위치 가져오기
      _currentPosition = await _locationService.getCurrentLocation();
      
      if (_currentPosition == null) {
        // 위치를 가져올 수 없으면 테스트용 위치 사용 (강남역)
        if (mounted) {
          setState(() {
            _locationPermissionDenied = true;
            // 강남역 좌표로 테스트
            _currentPosition = Position(
              latitude: 37.4980,
              longitude: 127.0276,
              timestamp: DateTime.now(),
              accuracy: 10,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
            _locationName = '강남역 10번 출구';
            _locationAddress = '서울특별시 강남구 역삼동';
          });
        }
      } else {
        // 실제 위치 정보 가져오기
        if (mounted) {
          setState(() {
            _locationName = '현재 위치';
            _locationAddress = '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}';
          });
        }
      }
      
      if (_currentPosition != null) {
        // 주변 가맹점 검색
        await _searchNearbyPlaces();
      }
    } catch (e) {
      print('데이터 로드 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _searchNearbyPlaces() async {
    if (_currentPosition == null) return;
    
    try {
      // 주변 가맹점 검색 (반경 200m)
      List<Place> places = await _placeService.searchNearbyPlacesAll(
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        radius: 200,
        sizePerCategory: 5,
      );
      
      // 각 가맹점에 대한 혜택 추천 요청
      _placesWithRecommendations = [];
      for (Place place in places) {
        RecommendResponse? recommendation = await _getRecommendationForPlace(place);
        if (recommendation != null) {
          _placesWithRecommendations.add(PlaceWithRecommendation(
            place: place,
            recommendation: recommendation,
          ));
        }
      }
      
      // 혜택 금액 순으로 정렬
      _placesWithRecommendations.sort((a, b) => 
        b.recommendation.expectedBenefit.compareTo(a.recommendation.expectedBenefit)
      );
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('주변 가맹점 검색 실패: $e');
    }
  }
  
  Future<RecommendResponse?> _getRecommendationForPlace(Place place) async {
    try {
      const userId = 'user_123';
      List<String> userCardIds = _userCards.map((uc) => uc.cardId).toList();
      
      if (userCardIds.isEmpty) {
        return null;
      }
      
      // 프리셋 금액
      int amount = 10000;
      
      List<RecommendResponse> recommendations = await _recommendService.getRecommendations(
        userId: userId,
        merchantCategory: place.category,
        merchantName: place.name,
        amount: amount,
        timestamp: DateTime.now(),
        userCards: userCardIds,
      );
      
      return recommendations.isNotEmpty ? recommendations.first : null;
    } catch (e) {
      print('혜택 추천 실패: ${place.name} - $e');
      return null;
    }
  }
  
  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'cafe':
        return '☕️';
      case 'food':
      case 'restaurant':
        return '🍽️';
      case 'movie':
      case 'culture':
        return '🎬';
      case 'convenience':
        return '🏪';
      case 'shopping':
        return '🛍️';
      default:
        return '📍';
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
    if (_locationPermissionDenied && _placesWithRecommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '위치 권한이 필요해요',
                style: AppTypography.t3,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '주변 혜택을 받으려면 위치 접근 권한을 허용해주세요.',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
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
                              _locationName,
                              style: AppTypography.t4,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _locationAddress,
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
                        '${_placesWithRecommendations.length}곳',
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
          if (_placesWithRecommendations.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '주변 가맹점을 찾지 못했어요',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _placesWithRecommendations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildRecommendationCard(item, index),
                    );
                  },
                  childCount: _placesWithRecommendations.length,
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

  Widget _buildRecommendationCard(PlaceWithRecommendation item, int index) {
    final place = item.place;
    final recommendation = item.recommendation;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CardDetailScreen(cardId: recommendation.cardId),
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
                    color: AppColors.primaryBlueLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryEmoji(place.category),
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
                              place.name,
                              style: AppTypography.body1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                                  '${place.distance}m',
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
                        place.category,
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
                color: AppColors.primaryBlueLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  // 카드 이모지
                  const Text(
                    '💳',
                    style: TextStyle(fontSize: 24),
                  ),
                  
                  const SizedBox(width: AppSpacing.sm),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.cardName,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              recommendation.benefitRate != null
                                  ? '${(recommendation.benefitRate! * 100).toStringAsFixed(0)}% 할인'
                                  : '${NumberFormat('#,###').format(recommendation.expectedBenefit)}원',
                              style: AppTypography.body1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            if (recommendation.conditions != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                recommendation.conditions!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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

// Place와 RecommendResponse를 함께 저장하는 클래스
class PlaceWithRecommendation {
  final Place place;
  final RecommendResponse recommendation;

  PlaceWithRecommendation({
    required this.place,
    required this.recommendation,
  });
}
