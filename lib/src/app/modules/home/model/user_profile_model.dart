class UserProfile {
  final String name;
  final String mobileNo;
  final String email;
  final String address;
  final String area;
  final int areaId;
  final String city;
  final String cityId;
  final String doorNo;
  final int points;
  final String image;
  final String latitude;
  final String longitude;
  final String locationUrl;
  final int unreadNotificationCount;

  UserProfile({
    required this.name,
    required this.mobileNo,
    required this.email,
    required this.address,
    required this.area,
    required this.areaId,
    required this.city,
    required this.cityId,
    required this.doorNo,
    required this.points,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.locationUrl,
    required this.unreadNotificationCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final userDetails = json['user_details'];
    return UserProfile(
      name: userDetails['name'] ?? '',
      mobileNo: userDetails['mobile_no']?.toString() ?? '',
      email: userDetails['email_id'] ?? '',
      address: userDetails['address'] ?? '',
      area: userDetails['area'] ?? '',
      areaId: userDetails['area_id'] ?? 0,
      city: userDetails['city'] ?? '',
      cityId: userDetails['city_id']?.toString() ?? '',
      doorNo: userDetails['door_no'] ?? '',
      points: userDetails['points'] ?? 0,
      image: userDetails['image'] ?? '',
      latitude: userDetails['latitude'] ?? '0.0',
      longitude: userDetails['longitude'] ?? '0.0',
      locationUrl: userDetails['location_url'] ?? '',
      unreadNotificationCount: json['unread_notification_count'] ?? 0,
    );
  }
}
