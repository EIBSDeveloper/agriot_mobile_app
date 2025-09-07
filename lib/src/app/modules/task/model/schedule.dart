class Schedule {
  Schedule({
    required this.id,
    required this.farmerId,
    required this.landId,
    required this.myCropId,
    required this.cropId,
    required this.crop,
    required this.cropImage,
    required this.activityTypeId,
    required this.activityType,
    required this.days,
    required this.description,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json['id'] ?? 0,
    farmerId: json['farmer_id'] ?? 0,
    landId: json['land_id'] ?? 0,
    myCropId: json['my_crop_id'] ?? 0,
    cropId: json['crop_id'] ?? 0,
    crop: json['crop'] ?? '',
    cropImage: json['crop_image'] ?? '',
    activityTypeId: json['activity_type_id'] ?? 0,
    activityType: json['activity_type'] ?? '',
    days: json['days'] ?? 0,
    description: json['description'] ?? '',
  );
  final int id;
  final int farmerId;
  final int landId;
  final int myCropId;
  final int cropId;
  final String crop;
  final String cropImage;
  final int activityTypeId;
  final String activityType;
  final int days;
  final String description;
}
