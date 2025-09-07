import 'package:argiot/src/app/modules/task/model/date_task.dart';
import 'package:argiot/src/app/modules/task/model/event.dart';

class TaskResponse {
  final List<DateTask> completedTasks;
  final List<DateTask> waitingTasks;
  final List<DateTask> cancelledTasks;
  final List<DateTask> pendingTasks;
  final List<DateTask> inProgressTasks;
  final List<Event> events;
  final String defaultLanguage;

  TaskResponse({
    required this.completedTasks,
    required this.waitingTasks,
    required this.cancelledTasks,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.events,
    required this.defaultLanguage,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) => TaskResponse(
      completedTasks: (json['completed_task'] as List)
          .map((e) => DateTask.fromJson(e))
          .toList(),
      waitingTasks: (json['waiting_task'] as List)
          .map((e) => DateTask.fromJson(e))
          .toList(),
      cancelledTasks: (json['cancelled_task'] as List)
          .map((e) => DateTask.fromJson(e))
          .toList(),
      pendingTasks: (json['pending_task'] as List)
          .map((e) => DateTask.fromJson(e))
          .toList(),
      inProgressTasks: (json['in_progress_task'] as List)
          .map((e) => DateTask.fromJson(e))
          .toList(),
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
      defaultLanguage: json['language']['default'] ?? 'en',
    );
}
