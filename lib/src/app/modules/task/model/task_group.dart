import 'package:argiot/src/app/modules/task/model/task.dart';

class TaskGroup {
  final String date;
  final String day;
  final List<Task> tasks;

  TaskGroup({required this.date, required this.day, required this.tasks});

  factory TaskGroup.fromJson(Map<String, dynamic> json) => TaskGroup(
      date: json['Date'],
      day: json['Day'],
      tasks: List<Task>.from(json['crop'].map((x) => Task.fromJson(x))),
    );
}
