class ScheduleStatus {
  final int id;
  final String name;

  ScheduleStatus({required this.id, required this.name});

  factory ScheduleStatus.fromJson(Map<String, dynamic> json) => ScheduleStatus(id: json['id'], name: json['name']);
}
