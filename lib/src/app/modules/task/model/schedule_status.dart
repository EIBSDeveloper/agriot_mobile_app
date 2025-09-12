import 'package:argiot/src/app/service/utils/utils.dart';

import '../../../service/utils/enums.dart';

class ScheduleStatus {
  final TaskTypes id;
  final String name;

  ScheduleStatus({required this.id, required this.name});

  factory ScheduleStatus.fromJson(Map<String, dynamic> json) =>
      ScheduleStatus(id: getTaskStatus(json['id']), name: json['name']);
}
