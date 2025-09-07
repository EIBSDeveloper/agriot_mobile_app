class ScheduleActivityType {
  final int id;
  final String name;

  ScheduleActivityType({required this.id, required this.name});

  factory ScheduleActivityType.fromJson(Map<String, dynamic> json) => ScheduleActivityType(id: json['id'], name: json['name']);
}
