class Schedule {
  final int id;
  final String activityType;
  final String startDate;
  final String endDate;
  final String status;
  final String schedule;
  final String comment;

  Schedule({
    required this.id,
    required this.activityType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.schedule,
    required this.comment,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
      id: json['schedule_id'],
      activityType: json['schedule_activity_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['schedule_status'],
      schedule: json['schedule']??" ",
      comment: json['comment'] ?? '',
    );
}
