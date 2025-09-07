import 'package:argiot/src/app/modules/task/model/schedule.dart';
import 'package:argiot/src/app/modules/task/model/schedule_crop.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';
import 'package:argiot/src/app/modules/task/repostory/schedule_repository.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/task/model/activity_model.dart';
import 'package:argiot/src/app/modules/task/model/task_request.dart';
import 'package:argiot/src/app/modules/task/view/widget/add_schedule.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ScheduleController extends GetxController {
  final ScheduleRepository _repository = ScheduleRepository();
  final AppDataController _appDataController = Get.find();
  RxList<ScheduleLand> lands = <ScheduleLand>[].obs;
  Rxn<ScheduleLand> selectedLand = Rxn<ScheduleLand>();
  Rxn<ScheduleCrop> selectedCrop = Rxn<ScheduleCrop>();
  RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  RxList<Schedule> schedules = <Schedule>[].obs;
  RxList<Schedule> filteredSchedules = <Schedule>[].obs;
  Rx<Schedule> selectedSchedule = Schedule(
    id: 0,
    farmerId: 0,
    landId: 0,
    myCropId: 0,
    cropId: 0,
    crop: '',
    cropImage: '',
    activityTypeId: 0,
    activityType: '',
    days: 0,
    description: '',
  ).obs;

  RxString searchQuery = ''.obs;

  // Parameters for API calls
  RxInt farmerId = 0.obs;
  RxInt landId = 0.obs;
  RxInt cropId = 0.obs;
  RxInt scheduleId = 0.obs;
  final RxList<ActivityModel> activity = <ActivityModel>[].obs;
  final Rx<ActivityModel> selectedActivityType = ActivityModel(
    id: 0,
    name: '',
  ).obs;

  final Rx<ScheduleCrop> selectedCropType = ScheduleCrop(id: 1, name: "").obs;
  // Form fields
  final Rx<DateTime> scheduleDate = DateTime.now().obs;
  final Rx<DateTime?> scheduleEndDate = Rx<DateTime?>(null);
  final RxString description = ''.obs;
  final RxBool isRecurring = false.obs;
  final RxInt recurrenceType = 0.obs; // 0: daily, 1: weekly, 2: monthly
  final RxList<int> selectedDays = <int>[].obs;

  final RxInt selectedMonth = 0.obs;
  final RxString selectedDateFilter = 'Today'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchLandsAndCrops();

    debounce(
      searchQuery,
      (_) => filterSchedules(),
      time: const Duration(milliseconds: 500),
    );
  }

  void addScheduleBottomSheet() {
    Get.bottomSheet(AddSchedule(), isScrollControlled: true);
  }

  Future<void> addTask() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final farmerId = _appDataController.userId.value;
    try {
      isLoading(true);
      final taskRequest = TaskRequest(
        farmerId: farmerId,
        myCrop: selectedSchedule.value.myCropId,
        scheduleActivityType: selectedSchedule.value.activityTypeId,
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

      Get
        ..back(result: true)
        ..back(result: true);
      showSuccess('Task added successfully');
    } catch (e) {
      showError('Failed to add task: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchLandsAndCrops() async {
    try {
      isLoading(true);
      final result = await _repository.fetchLandsAndCrops();
      lands.assignAll(result);

      await selectLand(result.first);
      final activityList = await _repository.getActivityTypes();
      activity.assignAll(activityList);
    } catch (e) {
      print('Error fetching lands and crops: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> selectLand(ScheduleLand? land) async {
    selectedLand.value = land;
    if (land!.crops.isNotEmpty) {
      selectedCrop.value = land.crops.first;
      await fetchSchedules();
    }
  }

  Future<void> selectCrop(ScheduleCrop? crop) async {
    selectedCrop.value = crop;
    await fetchSchedules();
  }

  List<ScheduleCrop> get cropsForSelectedLand =>
      selectedLand.value?.crops ?? [];

  void setParameters({required int lId, required int cId, int sId = 0}) {
    landId.value = lId;
    cropId.value = cId;
    scheduleId.value = sId;
  }

  Future<void> fetchSchedules() async {
    try {
      isLoading(true);
      final result = await _repository.fetchSchedules(
        selectedLand.value!.id,
        selectedCrop.value!.id,
      );
      schedules.assignAll(result);
      filteredSchedules.assignAll(result);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'failed_to_load_schedules'.tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchScheduleDetails() async {
    try {
      isLoading(true);
      final result = await _repository.fetchScheduleDetails(
        selectedLand.value!.id,
        selectedCrop.value!.id,
        scheduleId.value,
      );
      selectedSchedule(result);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'failed_to_load_schedule_details'.tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  void filterSchedules() {
    if (searchQuery.isEmpty) {
      filteredSchedules.assignAll(schedules);
    } else {
      filteredSchedules.assignAll(
        schedules.where(
          (schedule) =>
              schedule.crop.toLowerCase().contains(searchQuery.toLowerCase()) ||
              schedule.activityType.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              schedule.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
        ),
      );
    }
  }
}
