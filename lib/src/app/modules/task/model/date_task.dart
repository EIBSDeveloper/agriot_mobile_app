
import 'task.dart';

class DateTask {
  final String date;
  final List<Task> tasks;
  final int count;

  DateTask({required this.date, required this.tasks, required this.count});

  factory DateTask.fromJson(Map<String, dynamic> json) => DateTask(
      date: json['Date'],
      tasks: (json['tasks'] as List).map((e) => Task.fromJson(e)).toList(),
      count: json['count'],
    );
}
