class Place {
  final String id;
  final String name;
  final String category;
  final String kakaoCategory;
  final String address;
  final String? roadAddress;
  final String? phone;
  final double lat;
  final double lng;
  final int distance; // 미터 단위
  final String? placeUrl;

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.kakaoCategory,
    required this.address,
    this.roadAddress,
    this.phone,
    required this.lat,
    required this.lng,
    required this.distance,
    this.placeUrl,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      kakaoCategory: json['kakao_category'],
      address: json['address'],
      roadAddress: json['road_address'],
      phone: json['phone'],
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
      distance: json['distance'],
      placeUrl: json['place_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'kakao_category': kakaoCategory,
      'address': address,
      'road_address': roadAddress,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      'distance': distance,
      'place_url': placeUrl,
    };
  }
}

