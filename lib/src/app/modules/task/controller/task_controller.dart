import 'package:argiot/src/app/modules/task/model/activity_model.dart';
import 'package:argiot/src/app/modules/task/model/crop_model.dart';
import 'package:argiot/src/app/modules/task/model/date_task.dart';
import 'package:argiot/src/app/modules/task/model/event.dart';
import 'package:argiot/src/app/modules/task/model/task_group.dart';
import 'package:argiot/src/app/modules/task/model/task_request.dart';
import 'package:argiot/src/app/modules/task/model/task_response.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../controller/app_controller.dart';
import '../../../service/utils/enums.dart';
import '../../near_me/model/models.dart';

import '../model/task.dart';
import '../repostory/task_repository.dart';
import 'dart:async';

import '../view/widget/add_task.dart';

class TaskController extends GetxController {
  final TaskRepository _repository = TaskRepository();
  final RxList<TaskGroup> taskGroups = <TaskGroup>[].obs;
  final Rx<Land> selectedLand = Land(id: 0, name: '').obs;
  final Rx<CropModel> selectedCropType = CropModel(id: 0, name: '').obs;
  final Rx<ActivityModel> selectedActivityType = ActivityModel(
    id: 0,
    name: '',
  ).obs;
  final RxList<Land> lands = <Land>[].obs;
  final RxList<ActivityModel> activity = <ActivityModel>[].obs;
  final RxList<CropModel> crop = <CropModel>[].obs;
  final RxString selectedDateFilter = 'Today'.obs;
  final RxBool isList = true.obs;
  final RxBool isLoading = false.obs;

  final RxInt selectedMonth = 0.obs;

  // Form fields
  final Rx<DateTime> scheduleDate = DateTime.now().obs;
  final Rx<DateTime?> scheduleEndDate = Rx<DateTime?>(null);
  final RxString description = ''.obs;
  final RxBool isRecurring = false.obs;
  final RxBool endDate = true.obs;
  final RxInt recurrenceType = 0.obs; // 0: daily, 1: weekly, 2: monthly
  final RxList<int> selectedDays = <int>[].obs;

  final formKey = GlobalKey<FormState>();
  final AppDataController _appDataController = Get.find();

  // Task view related
  final Rx<TaskResponse?> taskResponse = Rx<TaskResponse?>(null);
  final Rx<TaskTypes> selectedFilter =  TaskTypes.all.obs;
  final RxBool cisLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = DateTime.now().month;
    fetchLands();
  }

  Future<void> fetchLands() async {
    try {
      isLoading(true);
      final landList = await _repository.getLands();
      lands.assignAll(landList.lands);

      if (lands.isNotEmpty) {
        selectedLand.value = lands.first;
        loadTasks();
      }

      final activityList = await _repository.getActivityTypes();
      activity.assignAll(activityList);

      final cropList = await _repository.getCropList();
      crop.assignAll(cropList);

      if (cropList.isNotEmpty) {
        selectedCropType.value = cropList.first;
      }
      if (activityList.isNotEmpty) {
        selectedActivityType.value = activityList.first;
      }
    } catch (e) {
      _showError('Failed to load lands: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void changeLand(Land land) {
    selectedLand.value = land;
    loadTasks();
  }

  void changeCrop(CropModel crop) {
    selectedCropType.value = crop;
  }

  void changeActivity(ActivityModel activity) {
    selectedActivityType.value = activity;
  }

  Future<void> loadTasks() async {
    await fetchTasks();
    await taskList();
  }

  Future<void> taskList() async {
     try {
      
      isLoading(true);
      taskGroups.clear();
    
      final tasks = await _repository.getTaskList(
        landId: selectedLand.value.id,
        month: selectedMonth.value,
      );
      taskGroups.assignAll(tasks);
      errorMessage.value = '';
    } catch (e) {
      _showError('Failed to load tasks: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addTask() async {
    if (!formKey.currentState!.validate()) return;

    final farmerId = _appDataController.farmerId.value;
    try {
      isLoading(true);
      final taskRequest = TaskRequest(
        farmerId: farmerId,
        myCrop: selectedCropType.value.id,
        scheduleActivityType: selectedActivityType.value.id,
        startDate: scheduleDate.value,
        endDate: isRecurring.value ? scheduleEndDate.value : null,
        scheduleChoice: isRecurring.value ? recurrenceType.value : 0,
        scheduleWeekly: isRecurring.value && recurrenceType.value == 1
            ? selectedDays
            : null,
        scheduleStatus: 1,
        schedule: description.value,
      );

      await _repository.addTask(taskRequest);
      await loadTasks();
      Get.back();
      _showSuccess('Task added successfully');
    } catch (e) {
      _showError('Failed to add task: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> editTask(int taskId, {int status = 0}) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading(true);
      final taskRequest = {
        "id": taskId,
        "my_crop": selectedCropType.value.id,
        "start_date": scheduleDate.value,
        "schedule": description.value,
        "schedule_status": status,
        "schedule_choice": isRecurring.value ? recurrenceType.value : 1,
      };

      await _repository.editTask(taskRequest);
      await loadTasks();
      Get.back();
      _showSuccess('Task updated successfully');
    } catch (e) {
      _showError('Failed to update task: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      isLoading(true);
      await _repository.deleteTask(taskId);
      _showSuccess('Task deleted successfully');
      await loadTasks();
    } catch (e) {
      _showError('Failed to delete task');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchTasks() async {
    try {
      isLoading(true);
      errorMessage('');

      final landId = selectedLand.value.id.toString();

      final response = await _repository.fetchTasks(
        landId: landId,
        month: selectedMonth.value,
      );

      taskResponse(response);
      await _initializeTodayTasks(response);
    } catch (e) {
      errorMessage(e.toString());
      _showError('Failed to load tasks: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
  void showAddTaskBottomSheet() {
    resetForm();
    Get.bottomSheet(const AddTask(), isScrollControlled: true);
  }
  _initializeTodayTasks(TaskResponse response) {
    if (response.events.isNotEmpty) {
      final todayEvents = response.events
          .where(
            (e) => e.date == DateFormat('yyyy-MM-dd').format(DateTime.now()),
          )
          .toList();

      if (todayEvents.isNotEmpty) {
        selectedDay.refresh();
      }
    }
    return;
  }

  void resetForm() {
    if (crop.isNotEmpty) selectedCropType.value = crop.first;
    if (activity.isNotEmpty) selectedActivityType.value = activity.first;
    scheduleDate.value = DateTime.now();
    scheduleEndDate.value = null;
    description.value = '';
    isRecurring.value = false;
    recurrenceType.value = 0;
    selectedDays.clear();
  }

  void changeFilter(TaskTypes filter) {
    selectedFilter.value = filter;
    update();
  }

  void changeCalendarFormat(CalendarFormat format) {
    calendarFormat.value = format;
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    this.selectedDay.value = selectedDay;
    this.focusedDay.value = focusedDay;
    update();
  }

  void onPageChanged(DateTime focusedDay) {
    this.focusedDay.value = focusedDay;
  }

  List<Event> getEventsForDay(DateTime day) {
    if (taskResponse.value == null) return [];
    final dateString = DateFormat('yyyy-MM-dd').format(day);
    return taskResponse.value!.events
        .where((event) => event.date == dateString)
        .toList();
  }

  List<Task> getTasksForDay(DateTime day) {
    if (taskResponse.value == null) return [];
    final dateString = DateFormat('yyyy-MM-dd').format(day);
    final allTasks = <Task>[];

    allTasks.addAll(
      _getTasksFromDateTasks(taskResponse.value!.completedTasks, dateString),
    );
    allTasks.addAll(
      _getTasksFromDateTasks(taskResponse.value!.waitingTasks, dateString),
    );
    allTasks.addAll(
      _getTasksFromDateTasks(taskResponse.value!.cancelledTasks, dateString),
    );
    allTasks.addAll(
      _getTasksFromDateTasks(taskResponse.value!.pendingTasks, dateString),
    );
    allTasks.addAll(
      _getTasksFromDateTasks(taskResponse.value!.inProgressTasks, dateString),
    );
    update();
    return _applyFilter(allTasks);
  }

  List<Task> _getTasksFromDateTasks(
    List<DateTask> dateTasks,
    String dateString,
  ) {
    final dateTask = dateTasks.firstWhere(
      (dt) => dt.date == dateString,
      orElse: () => DateTask(date: '', tasks: [], count: 0),
    );
    return dateTask.tasks;
  }

  List<Task> _applyFilter(List<Task> tasks) {
    switch (selectedFilter.value) {
      case  TaskTypes.completed:
        return tasks.where((task) => task.status ==  TaskTypes.completed).toList();
      case  TaskTypes.waiting:
        return tasks.where((task) => task.status ==  TaskTypes.waiting).toList();
      case  TaskTypes.inProgress:
        return tasks.where((task) => task.status ==  TaskTypes.inProgress).toList();
      case  TaskTypes.pending:
        return tasks.where((task) => task.status ==  TaskTypes.pending).toList();
      case   TaskTypes.cancelled:
        return tasks.where((task) => task.status ==  TaskTypes.cancelled).toList();
      default:
        return tasks;
    }
  }



  int getTotalTaskCount() {
    if (taskResponse.value == null) return 0;
    return taskResponse.value!.completedTasks.fold<int>(
          0,
          (sum, dt) => sum + dt.count,
        ) +
        taskResponse.value!.waitingTasks.fold<int>(
          0,
          (sum, dt) => sum + dt.count,
        ) +
        taskResponse.value!.cancelledTasks.fold<int>(
          0,
          (sum, dt) => sum + dt.count,
        ) +
        taskResponse.value!.pendingTasks.fold<int>(
          0,
          (sum, dt) => sum + dt.count,
        ) +
        taskResponse.value!.inProgressTasks.fold<int>(
          0,
          (sum, dt) => sum + dt.count,
        );
  }

  void refreshData({int? month}) {
    selectedMonth.value = month ?? selectedMonth.value;
    loadTasks();
  }

  void _showError(String message) {
    errorMessage(message);
    showError(message);
  }

  void _showSuccess(String message) {
    showSuccess(message);
  }
}
