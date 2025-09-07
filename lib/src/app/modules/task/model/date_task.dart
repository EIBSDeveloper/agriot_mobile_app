import 'package:argiot/src/app/modules/task/model/c_task.dart';

class DateTask {
  final String date;
  final List<CTask> tasks;
  final int count;

  DateTask({required this.date, required this.tasks, required this.count});

  factory DateTask.fromJson(Map<String, dynamic> json) => DateTask(
      date: json['Date'],
      tasks: (json['tasks'] as List).map((e) => CTask.fromJson(e)).toList(),
      count: json['count'],
    );
}
