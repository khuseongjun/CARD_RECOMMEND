/// 위치 서비스
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// 위치 권한 확인
  Future<bool> checkPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// 위치 권한 요청
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// 현재 위치 조회
  Future<Position?> getCurrentPosition() async {
    try {
      // 권한 확인
      bool hasPermission = await checkPermission();
      if (!hasPermission) {
        hasPermission = await requestPermission();
      }

      if (!hasPermission) {
        return null;
      }

      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // 현재 위치 조회
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print('위치 조회 실패: $e');
      return null;
    }
  }

  /// 위치 변경 스트림 (실시간 추적)
  Stream<Position> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // 20m 이동 시마다 업데이트
      timeLimit: Duration(seconds: 30), // 30초마다 업데이트
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 두 지점 간 거리 계산 (미터)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// 거리 포맷팅 (m 또는 km)
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }
}

