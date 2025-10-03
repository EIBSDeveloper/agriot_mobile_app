import '../../../service/utils/enums.dart';
import '../../../service/utils/utils.dart';
class Task {
  final int id;
  final String? cropType;
  final String? cropImage;
  final String? activityTypeName;
  final String description;
  final TaskTypes? status;
  final DateTime? taskDate;

  Task({
    required this.id,
    required this.cropType,
    required this.cropImage,
    required this.activityTypeName,
    required this.description,
    required this.taskDate,
    this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    var status = json['status_id'] ?? json['schedule_status'];
    var status2 = status != null ? getTaskStatus(status) : null;
    return Task(
      id: json['id'] ?? json['task_id'],
      cropType: json['crop_type'] ?? json['crop_name'],
      activityTypeName: json['activity_type_name'] ?? json['activity_type'] ?? '',
      cropImage: json['crop_image'],
      description: json['description'] ?? "",
      status: status2,
      taskDate: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'crop_type': cropType,
        'crop_image': cropImage,
        'description': description,
        'status': status?.toString(),
        'task_date': taskDate?.toIso8601String(),
      };

  Task copyWith({
    int? id,
    String? cropType,
    String? cropImage,
    String? activityTypeName,
    String? description,
    TaskTypes? status,
    DateTime? taskDate,
  }) =>
      Task(
        id: id ?? this.id,
        cropType: cropType ?? this.cropType,
        cropImage: cropImage ?? this.cropImage,
        activityTypeName: activityTypeName ?? this.activityTypeName,
        description: description ?? this.description,
        status: status ?? this.status,
        taskDate: taskDate ?? this.taskDate,
      );
}
