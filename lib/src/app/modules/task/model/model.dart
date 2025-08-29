import '../view/screens/screen.dart';

class Task {
  final int id;
  final String cropType;
  final String cropImage;
  final String description;

  Task({
    required this.id,
    required this.cropType,
    required this.cropImage,
    required this.description,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      cropType: json['crop_type'],
      cropImage: json['crop_image'],
      description: json['description'] ?? " ",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_type': cropType,
      'crop_image': cropImage,
      'description': description,
    };
  }
}

class TaskGroup {
  final String date;
  final String day;
  final List<Task> tasks;

  TaskGroup({required this.date, required this.day, required this.tasks});

  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    return TaskGroup(
      date: json['Date'],
      day: json['Day'],
      tasks: List<Task>.from(json['crop'].map((x) => Task.fromJson(x))),
    );
  }
}

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

class ActivityModel implements NamedItem {
  @override
  final int id;

  @override
  final String name;

  ActivityModel({required this.id, required this.name});

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(id: json['id'], name: json['name']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ActivityModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ActivityModel(id: $id, name: $name)';
}

class CropModel implements NamedItem {
  @override
  final int id;

  @override
  final String name;

  CropModel({required this.id, required this.name});

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(id: json['id'], name: json['name']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CropModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CropModel(id: $id, name: $name)';
}

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

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
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
}

class DateTask {
  final String date;
  final List<CTask> tasks;
  final int count;

  DateTask({required this.date, required this.tasks, required this.count});

  factory DateTask.fromJson(Map<String, dynamic> json) {
    return DateTask(
      date: json['Date'],
      tasks: (json['tasks'] as List).map((e) => CTask.fromJson(e)).toList(),
      count: json['count'],
    );
  }
}

class Event {
  final String date;
  final int count;
  final String status;
  final List<CTask> tasks;

  Event({
    required this.date,
    required this.count,
    required this.status,
    required this.tasks,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      date: json['Date'],
      count: json['count'],
      status: json['status'],
      tasks: (json['tasks'] as List).map((e) => CTask.fromJson(e)).toList(),
    );
  }
}

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

  factory CTask.fromJson(Map<String, dynamic> json) {
    return CTask(
      taskId: json['task_id'],
      activityTypeName: json['activity_type_name'],
      description: json['description'] ?? "",
      statusId: json['status_id'],
      status: json['status'],
    );
  }
}

class TaskDetails {
  final int farmerId;
  final int scheduleId;
  final TaskLand myLand;
  final TaskCrop myCrop;
  final ScheduleActivityType scheduleActivityType;
  final String startDate;
  final String endDate;
  final ScheduleStatus scheduleStatus;
  final int status;
  final String description;
  final String comment;
  // final List<CropExpense> cropExpenses;
  final double totalExpenseAmount;
  final Language language;

  TaskDetails({
    required this.farmerId,
    required this.scheduleId,
    required this.myLand,
    required this.myCrop,
    required this.scheduleActivityType,
    required this.startDate,
    required this.endDate,
    required this.scheduleStatus,
    required this.status,
    required this.description,
    required this.comment,
    // required this.cropExpenses,
    required this.totalExpenseAmount,
    required this.language,
  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) {
    return TaskDetails(
      farmerId: json['farmer_id'],
      scheduleId: json['schedule_id'],
      myLand: TaskLand.fromJson(json['my_land']),
      myCrop: TaskCrop.fromJson(json['my_crop']),
      scheduleActivityType: ScheduleActivityType.fromJson(
        json['schedule_activity_type'],
      ),
      startDate: json['start_date'],
      endDate: json['end_date'],
      scheduleStatus: ScheduleStatus.fromJson(json['schedule_status']),
      status: json['status'],
      description: json['description'] ?? " ",
      comment: json['comment'] ?? '',
      // cropExpenses: List<CropExpense>.from(json['crop_expenses'].map((x) => CropExpense.fromJson(x))),
      totalExpenseAmount: json['total_expense_amount']?.toDouble() ?? 0.0,
      language: Language.fromJson(json['language']),
    );
  }
}

class TaskLand {
  final int id;
  final String name;

  TaskLand({required this.id, required this.name});

  factory TaskLand.fromJson(Map<String, dynamic> json) {
    return TaskLand(id: json['id'], name: json['name']);
  }
}

class TaskCrop {
  final int id;
  final String name;
  final String cropImg;

  TaskCrop({required this.id, required this.name, required this.cropImg});

  factory TaskCrop.fromJson(Map<String, dynamic> json) {
    return TaskCrop(
      id: json['id'],
      name: json['name'],
      cropImg: json['crop_img'],
    );
  }
}

class ScheduleActivityType {
  final int id;
  final String name;

  ScheduleActivityType({required this.id, required this.name});

  factory ScheduleActivityType.fromJson(Map<String, dynamic> json) {
    return ScheduleActivityType(id: json['id'], name: json['name']);
  }
}

class ScheduleStatus {
  final int id;
  final String name;

  ScheduleStatus({required this.id, required this.name});

  factory ScheduleStatus.fromJson(Map<String, dynamic> json) {
    return ScheduleStatus(id: json['id'], name: json['name']);
  }
}

class Language {
  final String defaultLang;

  Language({required this.defaultLang});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(defaultLang: json['default']);
  }
}
