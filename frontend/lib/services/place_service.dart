import '../models/place.dart';
import 'api_client.dart';

class PlaceService {
  final ApiClient _apiClient = ApiClient();

  /// 주변 가맹점 검색
  Future<List<Place>> searchNearbyPlaces({
    required double lat,
    required double lng,
    int radius = 200,
    String? category,
    int size = 15,
  }) async {
    final response = await _apiClient.get(
      '/places/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
        if (category != null) 'category': category,
        'size': size,
      },
    );
    return (response.data as List)
        .map((json) => Place.fromJson(json))
        .toList();
  }

  /// 여러 카테고리의 주변 가맹점 검색
  Future<List<Place>> searchNearbyPlacesAll({
    required double lat,
    required double lng,
    int radius = 200,
    int sizePerCategory = 5,
  }) async {
    final response = await _apiClient.get(
      '/places/nearby/all',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
        'size_per_category': sizePerCategory,
      },
    );
    return (response.data as List)
        .map((json) => Place.fromJson(json))
        .toList();
  }
}

