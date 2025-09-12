
import 'task.dart';

class Event {
  final String date;
  final int count;
  final String status;
  final List<Task> tasks;

  Event({
    required this.date,
    required this.count,
    required this.status,
    required this.tasks,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    date: json['Date'],
    count: json['count'],
    status: json['status'],
    tasks: (json['tasks'] as List).map((e) => Task.fromJson(e)).toList(),
  );
}
