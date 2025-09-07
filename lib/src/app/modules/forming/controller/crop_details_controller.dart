import 'package:argiot/src/app/modules/forming/model/crop_overview.dart';
import 'package:argiot/src/app/modules/forming/model/my_crop_details.dart';
import 'package:argiot/src/app/modules/forming/repostroy/forming_repository.dart';
import 'package:argiot/src/app/modules/task/model/c_task.dart';
import 'package:argiot/src/app/modules/task/model/date_task.dart';
import 'package:argiot/src/app/modules/task/model/event.dart';
import 'package:argiot/src/app/modules/task/model/task_group.dart';
import 'package:argiot/src/app/modules/task/model/task_response.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../utils.dart';

class CropDetailsController extends GetxController {
  final FormingRepository _repository = Get.find();

  // Overview
  final Rx<CropOverview?> overview = Rx<CropOverview?>(null);
  final RxBool isOverviewLoading = false.obs;
  final RxString overviewError = ''.obs;

  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  RxInt landId = 0.obs;
  RxInt cropId = 0.obs;
  // Details
  final Rx<MyCropDetails?> details = Rx<MyCropDetails?>(null);
  final RxBool isDetailsLoading = false.obs;
  final RxString detailsError = ''.obs;
  final RxBool isList = true.obs;
  final RxBool isLoading = false.obs;

  final RxBool isCropExpended= false.obs;

  final RxList<TaskGroup> taskGroups = <TaskGroup>[].obs;

  // Task view related
  final Rx<TaskResponse?> taskResponse = Rx<TaskResponse?>(null);
  final RxString selectedFilter = 'all'.obs;
  final RxBool cisLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final Rx<CalendarFormat> calendarFormat = CalendarFormat.month.obs;

  Future<void> fetchCropOverview() async {
    try {
      isOverviewLoading(true);
      final data = await _repository.getCropOverview(
        landId.value,
        cropId.value,
      );
      overview(data);
      overviewError('');
    } catch (e) {
      overviewError(e.toString());
      showError('Failed to fetch crop overview');
    } finally {
      isOverviewLoading(false);
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      isOverviewLoading(true);
      await _repository.deleteTask(taskId);
      // _showSuccess('Task deleted successfully');
      await fetchCropOverview();
    } catch (e) {
      // _showError('Failed to delete task: ${e.toString()}');
    } finally {
      isOverviewLoading(false);
    }
  }
  Future<void> deleteCrop(int taskId) async {
    try {
      isOverviewLoading(true);
      await _repository.deleteCrop(taskId);
      // _showSuccess('Task deleted successfully');
      await fetchCropOverview();
    } catch (e) {
      // _showError('Failed to delete task: ${e.toString()}');
    } finally {
      isOverviewLoading(false);
    }
  }

  Future<void> fetchCropDetails(int landId, int cropId) async {
    try {
      isDetailsLoading(true);
      final data = await _repository.getCropDetails(landId, cropId);
      details(data);
      detailsError('');
    } catch (e) {
      detailsError(e.toString());
      showError('Failed to fetch crop details');
    } finally {
      isDetailsLoading(false);
    }
  }

  Future<void> updateCrop(Map<String, dynamic> data) async {
    try {
      isDetailsLoading(true);
      await _repository.updateCropDetails(data);
      Get.back();
      showSuccess('Crop updated successfully');
    } catch (e) {
      detailsError(e.toString());
      showError('Failed to update crop');
    } finally {
      isDetailsLoading(false);
    }
  }

  Future<void> loadTasks() async {
    try {
      await fetchTasks();
      isLoading(true);
      taskGroups.clear();

      final tasks = await _repository.getTaskList(
        landId: landId.value,
        month: selectedMonth.value,
        cropId: cropId.value,
      );
      taskGroups.assignAll(tasks);
      errorMessage.value = '';
    } catch (e) {
      _showError('Failed to load tasks: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    update();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _repository.fetchTasks(
        landId: landId.value.toString(),
        month: selectedMonth.value,   cropId:    cropId.value,
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

  // Helper to calculate days since plantation
  int getDaysSincePlantation(DateTime? plantationDate) {
    try {
      final now = DateTime.now();
      return now.difference(plantationDate!).inDays;
    } catch (e) {
      return 0;
    }
  }

  List<Event> getEventsForDay(DateTime day) {
    if (taskResponse.value == null) return [];
    final dateString = DateFormat('yyyy-MM-dd').format(day);
    return taskResponse.value!.events
        .where((event) => event.date == dateString)
        .toList();
  }

  void refreshData({DateTime? month}) {
    selectedMonth.value = month ?? selectedMonth.value;
    loadTasks();
  }

  List<CTask> getTasksForDay(DateTime day) {
    if (taskResponse.value == null) return [];
    final dateString = DateFormat('yyyy-MM-dd').format(day);
    final allTasks = <CTask>[];

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

  List<CTask> _getTasksFromDateTasks(
    List<DateTask> dateTasks,
    String dateString,
  ) {
    final dateTask = dateTasks.firstWhere(
      (dt) => dt.date == dateString,
      orElse: () => DateTask(date: '', tasks: [], count: 0),
    );
    return dateTask.tasks;
  }

  List<CTask> _applyFilter(List<CTask> tasks) {
    switch (selectedFilter.value) {
      case 'completed':
        return tasks.where((task) => task.statusId == 2).toList();
      case 'waiting':
        return tasks.where((task) => task.statusId == 1).toList();

      case 'in_progress':
        return tasks.where((task) => task.statusId == 3).toList();
      case 'pending':
        return tasks.where((task) => task.statusId == 4).toList();
      case 'cancelled':
        return tasks.where((task) => task.statusId == 5).toList();
      default:
        return tasks;
    }
  }

  Map<DateTime, List<Event>> get events {
    if (taskResponse.value == null) return {};
    final eventsMap = <DateTime, List<Event>>{};
    for (final event in taskResponse.value!.events) {
      final date = DateFormat('yyyy-MM-dd').parse(event.date);
      eventsMap[date] = eventsMap[date] ?? [];
      eventsMap[date]!.add(event);
    }
    return eventsMap;
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

  void _showError(String message) {
    errorMessage(message);
    showError(message);
  }

}
