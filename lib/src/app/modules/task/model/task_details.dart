
import 'package:argiot/src/app/modules/task/model/schedule_activity_type.dart';
import 'package:argiot/src/app/modules/task/model/schedule_status.dart';
import 'package:argiot/src/app/modules/task/model/task_crop.dart';
import 'package:argiot/src/app/modules/task/model/task_land.dart';
import 'package:argiot/src/app/service/utils/utils.dart';

import '../../../service/utils/enums.dart';

class TaskDetails {
  final int farmerId;
  final int scheduleId;
  final TaskLand myLand;
  final TaskCrop myCrop;
  final ScheduleActivityType scheduleActivityType;
  final String startDate;
  final String endDate;
  final ScheduleStatus scheduleStatus;
  final TaskTypes status;
  final String description;
  final String comment;
  // final List<CropExpense> cropExpenses;
  final double totalExpenseAmount;


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

  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) => TaskDetails(
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
      status: getTaskStatus(json['status']??0),
      description: json['description'] ?? "",
      comment: json['comment'] ?? '',
      // cropExpenses: List<CropExpense>.from(json['crop_expenses'].map((x) => CropExpense.fromJson(x))),
      totalExpenseAmount: json['total_expense_amount']?.toDouble() ?? 0.0,
    
    );
}
