class DashBoardSchedule {
  int id;
  String schedule;
  String startDate;
  String endDate;
  int scheduleStatus;
  String scheduleStatusName;
  dynamic comment;
  int scheduleChoice;
  DateTime createdAt;
  DateTime updatedAt;
  int myLandId;
  String landName;
  int farmerId;
  String farmerName;
  int cropId;
  String cropName;
  String cropImage;

  DashBoardSchedule({
    required this.id,
    required this.schedule,
    required this.startDate,
    required this.endDate,
    required this.scheduleStatus,
    required this.scheduleStatusName,
    required this.comment,
    required this.scheduleChoice,
    required this.createdAt,
    required this.updatedAt,
    required this.myLandId,
    required this.landName,
    required this.farmerId,
    required this.farmerName,
    required this.cropId,
    required this.cropName,
    required this.cropImage,
  });

  factory DashBoardSchedule.fromJson(Map<String, dynamic> json) =>
      DashBoardSchedule(
        id: json["id"],
        schedule: json["schedule"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        scheduleStatus: json["schedule_status"],
        scheduleStatusName: json["schedule_status_name"],
        comment: json["comment"],
        scheduleChoice: json["schedule_choice"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        myLandId: json["my_land_id"],
        landName: json["land_name"],
        farmerId: json["farmer_id"],
        farmerName: json["farmer_name"],
        cropId: json["crop_id"],
        cropName: json["crop_name"],
        cropImage: json["crop_image"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "schedule": schedule,
    "start_date": startDate,
    "end_date": endDate,
    "schedule_status": scheduleStatus,
    "schedule_status_name": scheduleStatusName,
    "comment": comment,
    "schedule_choice": scheduleChoice,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "my_land_id": myLandId,
    "land_name": landName,
    "farmer_id": farmerId,
    "farmer_name": farmerName,
    "crop_id": cropId,
    "crop_name": cropName,
    "crop_image": cropImage,
  };
}
