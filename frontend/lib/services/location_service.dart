import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// 위치 권한 요청
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // 설정에서 권한을 허용하도록 안내
      await openAppSettings();
      return false;
    }
    
    return true;
  }

  /// 현재 위치 가져오기
  Future<Position?> getCurrentLocation() async {
    bool hasPermission = await requestPermission();
    if (!hasPermission) {
      return null;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('위치 가져오기 실패: $e');
      return null;
    }
  }

  /// 위치 스트림 구독 (distanceFilter 또는 interval)
  Stream<Position> getLocationStream({
    double distanceFilter = 30.0, // 20-30m
    Duration? interval, // 20-30초
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async* {
    if (interval != null) {
      // interval 방식 - 주기적으로 위치 업데이트
      while (true) {
        Position? position = await getCurrentLocation();
        if (position != null) {
          yield position;
        }
        await Future.delayed(interval);
      }
    } else {
      // distanceFilter 방식
      yield* Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter.toInt(), // int로 변환
        ),
      );
    }
  }

  /// 두 위치 사이의 거리 계산 (미터)
  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}

