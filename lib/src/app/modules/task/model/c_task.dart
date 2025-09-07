class CTask {
  final int taskId;
  final String activityTypeName;
  final String description;
  final int statusId;
  final String status;

  CTask({
    required this.taskId,
    required this.activityTypeName,
    required this.description,
    required this.statusId,
    required this.status,
  });

  factory CTask.fromJson(Map<String, dynamic> json) => CTask(
      taskId: json['task_id'],
      activityTypeName: json['activity_type_name'],
      description: json['description'] ?? "",
      statusId: json['status_id'],
      status: json['status'],
    );
}
