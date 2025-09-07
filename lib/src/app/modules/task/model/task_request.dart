class TaskRequest {
  final String farmerId;
  final int myCrop;
  final int scheduleActivityType;
  final DateTime startDate;
  final DateTime? endDate;
  final int scheduleChoice;
  final List<int>? scheduleWeekly;
  final int scheduleStatus;
  final String schedule;

  TaskRequest({
    required this.farmerId,
    required this.myCrop,
    required this.scheduleActivityType,
    required this.startDate,
    this.endDate,
    required this.scheduleChoice,
    this.scheduleWeekly,
    required this.scheduleStatus,
    required this.schedule,
  });

  Map<String, dynamic> toJson() {
    var map = {
      'farmer': farmerId,
      'my_crop': myCrop,
      'schedule_activity_type': scheduleActivityType,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate != null
          ? endDate?.toIso8601String().split('T')[0]
          : startDate.toIso8601String().split('T')[0],
      'schedule_choice': scheduleChoice,
      if (scheduleWeekly != null) 'schedule_weekly': scheduleWeekly,
      'schedule_status': scheduleStatus,
      "schedule": schedule,
    };
    return map;
  }
}
