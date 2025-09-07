class CropTask {
  final int id;
  final String activityType;
  final String description;
  final int scheduleStatus;
  final String scheduleStatusName;

  CropTask({
    required this.id,
    required this.activityType,
    required this.description,
    required this.scheduleStatus,
    required this.scheduleStatusName,
  });

  factory CropTask.fromJson(Map<String, dynamic> json) => CropTask(
    id: json['id'] ?? 0,
    activityType: json['activity_type'] ?? '',
    description: json['description'] ?? '',
    scheduleStatus: json['schedule_status'] ?? 0,
    scheduleStatusName: json['schedule_status_name'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'activity_type': activityType,
    'description': description,
    'schedule_status': scheduleStatus,
    'schedule_status_name': scheduleStatusName,
  };
}
