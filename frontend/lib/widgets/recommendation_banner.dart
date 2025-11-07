/// 위치 기반 추천 배너 위젯
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../config/app_colors.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../providers/auth_provider.dart';
import '../models/recommendation_model.dart';
import '../screens/card_detail_screen.dart';

class RecommendationBanner extends ConsumerStatefulWidget {
  const RecommendationBanner({Key? key}) : super(key: key);

  @override
  ConsumerState<RecommendationBanner> createState() =>
      _RecommendationBannerState();
}

class _RecommendationBannerState extends ConsumerState<RecommendationBanner> {
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;
  
  RecommendationModel? _currentRecommendation;
  bool _isLoading = false;
  String? _error;
  Position? _lastPosition;
  DateTime? _lastRecommendationTime;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  /// 위치 추적 시작
  void _startLocationTracking() async {
    // 권한 확인
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      setState(() {
        _error = '위치 권한이 필요합니다';
      });
      return;
    }

    // 초기 위치 조회
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      _lastPosition = position;
      await _fetchRecommendation(position);
    }

    // 위치 변경 스트림 구독
    _positionSubscription = _locationService.getPositionStream().listen(
      (position) async {
        // 이전 위치와 비교 (20m 이상 이동 시에만 처리)
        if (_lastPosition != null) {
          final distance = _locationService.calculateDistance(
            _lastPosition!.latitude,
            _lastPosition!.longitude,
            position.latitude,
            position.longitude,
          );

          if (distance < 20) {
            return; // 20m 미만 이동 시 무시
          }
        }

        _lastPosition = position;

        // 중복 알림 방지 (20초 이내)
        if (_lastRecommendationTime != null) {
          final diff = DateTime.now().difference(_lastRecommendationTime!);
          if (diff.inSeconds < 20) {
            return;
          }
        }

        await _fetchRecommendation(position);
      },
      onError: (error) {
        setState(() {
          _error = '위치 추적 중 오류가 발생했습니다';
        });
      },
    );
  }

  /// 추천 가져오기
  Future<void> _fetchRecommendation(Position position) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated || authState.user == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final storageService = ref.read(storageServiceProvider);

      // 주변 장소 검색
      final places = await apiService.getNearbyPlaces(
        lat: position.latitude,
        lng: position.longitude,
        radius: 120,
      );

      if (places.isEmpty) {
        setState(() {
          _isLoading = false;
          _currentRecommendation = null;
        });
        return;
      }

      // 가장 가까운 장소 선택
      final nearestPlace = places.first;

      // 중복 알림 확인 (장소별 10분)
      if (!storageService.shouldShowNotification(nearestPlace.placeId)) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 카테고리 추출
      String category = _extractCategory(nearestPlace.categoryName);

      // 추천 요청
      final recommendations = await apiService.getRecommendations(
        userId: authState.user!.userId,
        merchantCategory: category,
        merchantName: nearestPlace.placeName,
        amount: 10000, // 기본 금액
        timestamp: DateTime.now().toIso8601String(),
        lat: position.latitude,
        lng: position.longitude,
      );

      if (recommendations.recommendations.isNotEmpty) {
        final topRecommendation = recommendations.recommendations.first;

        // 최소 절약액 필터 (300원 이상)
        if (topRecommendation.expectedSaving >= 300) {
          setState(() {
            _currentRecommendation = topRecommendation;
            _lastRecommendationTime = DateTime.now();
          });

          // 알림 시간 저장
          await storageService.saveLastNotificationTime(nearestPlace.placeId);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '추천을 가져올 수 없습니다';
      });
    }
  }

  /// 카테고리 추출
  String _extractCategory(String categoryName) {
    if (categoryName.contains('커피') || categoryName.contains('카페')) {
      return 'COFFEE';
    } else if (categoryName.contains('편의점')) {
      return 'CONVENIENCE_STORE';
    } else if (categoryName.contains('음식점')) {
      return 'RESTAURANT';
    } else if (categoryName.contains('마트')) {
      return 'MART';
    } else if (categoryName.contains('주유')) {
      return 'GAS_STATION';
    } else if (categoryName.contains('병원')) {
      return 'HOSPITAL';
    } else if (categoryName.contains('약국')) {
      return 'PHARMACY';
    } else {
      return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 추천이 없으면 표시하지 않음
    if (_currentRecommendation == null && !_isLoading && _error == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 16),
          Text(
            '주변 혜택을 찾는 중...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    if (_currentRecommendation != null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CardDetailScreen(
                cardId: _currentRecommendation!.cardId,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '🎯 지금 여기서',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 카드명
            Text(
              _currentRecommendation!.cardName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 혜택
            Text(
              _currentRecommendation!.benefitTitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // 예상 절약액
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💰 ${_currentRecommendation!.expectedSaving}원 절약',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // 조건
            if (_currentRecommendation!.conditions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _currentRecommendation!.conditions.first,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

