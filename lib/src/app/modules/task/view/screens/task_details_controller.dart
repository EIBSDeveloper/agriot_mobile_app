// lib/app/modules/task/models/task_model.dart

import 'package:argiot/src/app/modules/task/model/model.dart';
import 'package:argiot/src/app/modules/task/repostory/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TaskDetailsController extends GetxController {
  final TaskRepository _taskRepository = TaskRepository();
  final Rx<TaskDetails?> task = Rx<TaskDetails?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final int taskId;
  final formKey = GlobalKey<FormState>();
  final Rx<CropModel> selectedCropType = CropModel(id: 0, name: '').obs;
  final Rx<ActivityModel> selectedActivityType = ActivityModel(
    id: 0,
    name: '',
  ).obs;

  final RxList<ActivityModel> activity = <ActivityModel>[].obs;
  final RxList<CropModel> crop = <CropModel>[].obs;
  final Rx<DateTime> scheduleDate = DateTime.now().obs;
  final RxString description = ''.obs;
  final RxBool isLoadingEdit = false.obs;
  TaskDetailsController({required this.taskId});
  RxInt selectedValue = 1.obs;
  final List<Map<String, dynamic>> statusList = [
    {"name": "Waiting Completion", "value": 1},
    {"name": "Completed", "value": 2},
    {"name": "In Progress", "value": 3},
    {"name": "Pending", "value": 4},
    {"name": "Cancelled", "value": 5},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTaskDetails();
  }

  void changeCrop(CropModel crop) {
    selectedCropType.value = crop;
  }

  void changeActivity(ActivityModel activity) {
    selectedActivityType.value = activity;
  }

  Future<void> fetchTaskDetails() async {
    try {
      isLoading(true);
      errorMessage('');
      final TaskDetails fetchedTask = await _taskRepository.getTaskDetails(
        taskId,
      );
      task(fetchedTask);

      selectedValue.value = fetchedTask.scheduleStatus.id;

      final activityList = await _taskRepository.getActivityTypes();
      activity.assignAll(activityList);

      final cropList = await _taskRepository.getCropList();
      crop.assignAll(cropList);
      if (cropList.isNotEmpty) {
        selectedCropType.value = cropList.firstWhere(
          (e) => e.id == fetchedTask.myCrop.id,
          orElse: () => cropList.first,
        );
      }

      if (activityList.isNotEmpty) {
        selectedActivityType.value = activityList.firstWhere(
          (e) => e.id == fetchedTask.scheduleActivityType.id,
          orElse: () => activityList.first,
        );
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteTask() async {
    try {
      isLoading(true);
      await _taskRepository.deleteTask(taskId);
      Get.back(result: 'deleted');
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> addComment(String comment) async {
    try {
      isLoading(true);
      await _taskRepository.addComment(taskId, comment);
      await fetchTaskDetails(); // Refresh task details
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> markTaskCompleted() async {
    try {
      if (task.value == null) return;

      isLoading(true);
      await _taskRepository.markTaskCompleted(
        taskId,
        task.value!.myCrop.id,
        task.value!.startDate,
        task.value!.description,
        selectedValue.value,
      );
      await fetchTaskDetails(); // Refresh task details
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void prepareEditFields() {
    final task = this.task.value;
    if (task != null) {
      selectedCropType.value = CropModel(
        id: task.myCrop.id,
        name: task.myCrop.name,
      );
      selectedActivityType.value = ActivityModel(
        id: task.scheduleActivityType.id,
        name: task.scheduleActivityType.name,
      );
      scheduleDate.value = DateFormat("dd-MM-yyyy").parse(task.startDate);
      description.value = task.description;
    }
  }

  Future<void> updateTask(int taskId) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoadingEdit(true);
      final response = await _taskRepository.updateTask(
        id: taskId,
        myCrop: selectedCropType.value.id,
        startDate: scheduleDate.value,
        description: description.value,
        scheduleStatus: task.value?.status ?? 0,
      );
      if (response.isNotEmpty) {}
      await fetchTaskDetails(); // Refresh task details
      Get.back(); // Close the edit sheet
      Fluttertoast.showToast(msg: 'Task updated successfully');
    } catch (e) {
      errorMessage(e.toString());
      Fluttertoast.showToast(msg: 'Failed to update task: ${e.toString()}');
    } finally {
      isLoadingEdit(false);
    }
  }
}
