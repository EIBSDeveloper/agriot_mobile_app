// lib/modules/schedules/models/schedule_model.dart
import 'dart:convert';

import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'src/app/controller/app_controller.dart';
import 'src/app/modules/task/model/model.dart';
import 'src/app/utils/http/http_service.dart';
import 'src/app/widgets/input_card_style.dart';
import 'src/app/widgets/toggle_bar.dart';
import 'src/utils.dart';

// lib/common/models/land_crop_model.dart
class ScheduleLand {
  final int id;
  final String name;
  final List<ScheduleCrop> crops;

  ScheduleLand({required this.id, required this.name, required this.crops});

  factory ScheduleLand.fromJson(Map<String, dynamic> json) {
    return ScheduleLand(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      crops:
          (json['crops'] as List<dynamic>?)
              ?.map((cropJson) => ScheduleCrop.fromJson(cropJson))
              .toList() ??
          [],
    );
  }
}

class ScheduleCrop {
  final int id;
  final String name;

  ScheduleCrop({required this.id, required this.name});

  factory ScheduleCrop.fromJson(Map<String, dynamic> json) {
    return ScheduleCrop(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Schedule {
  final int id;
  final int farmerId;
  final int landId;
  final int myCropId;
  final int cropId;
  final String crop;
  final String cropImage;
  final int activityTypeId;
  final String activityType;
  final int days;
  final String description;

  Schedule({
    required this.id,
    required this.farmerId,
    required this.landId,
    required this.myCropId,
    required this.cropId,
    required this.crop,
    required this.cropImage,
    required this.activityTypeId,
    required this.activityType,
    required this.days,
    required this.description,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? 0,
      farmerId: json['farmer_id'] ?? 0,
      landId: json['land_id'] ?? 0,
      myCropId: json['my_crop_id'] ?? 0,
      cropId: json['crop_id'] ?? 0,
      crop: json['crop'] ?? '',
      cropImage: json['crop_image'] ?? '',
      activityTypeId: json['activity_type_id'] ?? 0,
      activityType: json['activity_type'] ?? '',
      days: json['days'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class ScheduleRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.put(AppDataController());
  Future<List<Schedule>> fetchSchedules(int landId, int cropId) async {
    try {
      final farmerId = appDeta.userId;
      final response = await _httpService.get(
        '/best_practice_schedule/$farmerId/$landId/$cropId/',
      );

      if (response.statusCode == 200) {
        final List<dynamic> schedulesJson = json.decode(
          response.body,
        )['schedules'];
        return schedulesJson.map((json) => Schedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Schedule> fetchScheduleDetails(
    int landId,
    int cropId,
    int scheduleId,
  ) async {
    try {
      final farmerId = appDeta.userId;
      final response = await _httpService.get(
        '/best_practice_schedule/$farmerId/$landId/$cropId/$scheduleId',
      );

      if (response.statusCode == 200) {
        Map decode = json.decode(response.body);

        var decode2 = decode["schedule"];
        final schedulesJson = decode2;
        if (schedulesJson.isNotEmpty) {
          return Schedule.fromJson(schedulesJson);
        } else {
          throw Exception('Schedule not found');
        }
      } else {
        throw Exception('Failed to load schedule details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ActivityModel>> getActivityTypes() async {
    try {
      final response = await _httpService.get('/schedule_activity_types');
      final data = json.decode(response.body)['data'] as List;
      return data.map((item) => ActivityModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load activity types: ${e.toString()}');
    }
  }

  Future<void> addTask(TaskRequest taskRequest) async {
    await _httpService.post('/new_task/', taskRequest.toJson());
  }

  Future<List<ScheduleLand>> fetchLandsAndCrops() async {
    final farmerId = appDeta.userId;
    try {
      final response = await _httpService.get(
        '/land-and-crop-details/$farmerId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> landsJson = json.decode(response.body)['lands'];
        return landsJson.map((json) => ScheduleLand.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lands and crops');
      }
    } catch (e) {
      rethrow;
    }
  }
}

// lib/modules/schedules/controllers/schedule_controller.dart

class ScheduleController extends GetxController {
  final ScheduleRepository _repository = ScheduleRepository();
  final AppDataController _appDataController = Get.find();
  var lands = <ScheduleLand>[].obs;
  var selectedLand = Rxn<ScheduleLand>();
  var selectedCrop = Rxn<ScheduleCrop>();
  var isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  var schedules = <Schedule>[].obs;
  var filteredSchedules = <Schedule>[].obs;
  var selectedSchedule = Schedule(
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

  var searchQuery = ''.obs;

  // Parameters for API calls
  var farmerId = 0.obs;
  var landId = 0.obs;
  var cropId = 0.obs;
  var scheduleId = 0.obs;
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
  void onInit() {
    super.onInit();
    fetchLandsAndCrops();
    debounce(
      searchQuery,
      (_) => filterSchedules(),
      time: const Duration(milliseconds: 500),
    );
  }

  void changeCrop(ScheduleCrop crop) {
    selectedCropType.value = crop;
  }

  Future<void> addTask() async {
    if (!formKey.currentState!.validate()) return;

    final farmerId = _appDataController.userId.value;
    try {
      isLoading(true);
      final taskRequest = TaskRequest(
        farmerId: farmerId,
        myCrop: selectedSchedule.value.myCropId,
        scheduleActivityType: selectedActivityType.value.id,
        startDate: scheduleDate.value,
        endDate: isRecurring.value ? scheduleEndDate.value : null,
        scheduleChoice: isRecurring.value ? recurrenceType.value : 0,
        scheduleWeekly: isRecurring.value && recurrenceType.value == 1
            ? selectedDays
            : null,
        scheduleStatus: 0,
        schedule: description.value,
      );

      await _repository.addTask(taskRequest);

      Get.back();
      showSuccess('Task added successfully');
    } catch (e) {
      showError('Failed to add task: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void changeActivity(ActivityModel activity) {
    selectedActivityType.value = activity;
  }

  Future<void> fetchLandsAndCrops() async {
    try {
      isLoading(true);
      final result = await _repository.fetchLandsAndCrops();
      lands.assignAll(result);

      selectedLand.value = result.first;
      final activityList = await _repository.getActivityTypes();
      activity.assignAll(activityList);
      if (result.first.crops.isNotEmpty) {
        selectedCrop.value = result.first.crops.first;
      }
    } catch (e) {
      print('Error fetching lands and crops: $e');
    } finally {
      isLoading(false);
    }
  }

  void selectLand(ScheduleLand? land) {
    selectedLand.value = land;
    if (land!.crops.isNotEmpty) {
      selectedCrop.value = land.crops.first;
      fetchSchedules();
    }
  }

  void selectCrop(ScheduleCrop? crop) {
    selectedCrop.value = crop;
    fetchSchedules();
  }

  List<ScheduleCrop> get cropsForSelectedLand {
    return selectedLand.value?.crops ?? [];
  }

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

// lib/modules/schedules/bindings/schedule_binding.dart

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleController>(() => ScheduleController());
  }
}

// lib/modules/schedules/views/schedule_list_page.dart

class ScheduleListPage extends GetView<ScheduleController> {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'schedules'.tr),
      body: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return InputCardStyle(
                      child: DropdownButtonFormField<ScheduleLand>(
                        value: controller.selectedLand.value,

                        items: controller.lands.map((ScheduleLand land) {
                          return DropdownMenuItem<ScheduleLand>(
                            value: land,
                            child: Text(land.name),
                          );
                        }).toList(),
                        onChanged: (ScheduleLand? land) {
                          controller.selectLand(land);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Land',
                          border: InputBorder.none,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final crops = controller.cropsForSelectedLand;

                    if (controller.selectedLand.value == null) {
                      return InputCardStyle(
                        child: DropdownButtonFormField(
                          items: [],
                          onChanged: null,
                          decoration: InputDecoration(
                            labelText: 'Select land first',
                            border: InputBorder.none,
                          ),
                        ),
                      );
                    }

                    return InputCardStyle(
                      child: DropdownButtonFormField<ScheduleCrop>(
                        value: controller.selectedCrop.value,

                        items: crops.map((ScheduleCrop crop) {
                          return DropdownMenuItem<ScheduleCrop>(
                            value: crop,
                            child: Text(crop.name),
                          );
                        }).toList(),
                        onChanged: (ScheduleCrop? crop) {
                          controller.selectCrop(crop);
                        },
                        decoration: InputDecoration(
                          hintText: 'Crop',
                          border: InputBorder.none,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: TextField(
          //     onChanged: (value) => controller.searchQuery(value),
          //     decoration: InputDecoration(
          //       hintText: 'search_schedules'.tr,
          //       prefixIcon: const Icon(Icons.search),
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(10.0),
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredSchedules.isEmpty) {
                return Center(child: Text('no_schedules_found'.tr));
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchSchedules(),
                child: ListView.builder(
                  itemCount: controller.filteredSchedules.length,
                  itemBuilder: (context, index) {
                    final schedule = controller.filteredSchedules[index];
                    return ScheduleCard(
                      schedule: schedule,
                      controller: controller,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final ScheduleController controller;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 1,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CachedNetworkImage(
            imageUrl: schedule.cropImage,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(width: 50, height: 50, color: Colors.grey[300]),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        title: Text(schedule.crop),
        subtitle: Text(schedule.activityType),
        trailing: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            controller.setParameters(
              lId: schedule.cropId,
              cId: schedule.cropId,
              sId: schedule.id,
            );

            // Delay execution until after the first build

            await controller.fetchScheduleDetails();
            addScheduleBottomSheet();
          },
        ),
        onTap: () {
          Get.toNamed(
            '/schedule-details',
            arguments: {
              'landId': schedule.cropId,
              'cropId': schedule.cropId,
              'scheduleId': schedule.id,
            },
          );
        },
      ),
    );
  }
}

// lib/modules/schedules/views/schedule_details_page.dart

class ScheduleDetailsPage extends StatefulWidget {
  final int landId;
  final int cropId;
  final int scheduleId;

  const ScheduleDetailsPage({
    super.key,
    required this.landId,
    required this.cropId,
    required this.scheduleId,
  });

  @override
  State<ScheduleDetailsPage> createState() => _ScheduleDetailsPageState();
}

class _ScheduleDetailsPageState extends State<ScheduleDetailsPage> {
  final ScheduleController controller = Get.find<ScheduleController>();

  @override
  void initState() {
    super.initState();
    controller.setParameters(
      lId: widget.landId,
      cId: widget.cropId,
      sId: widget.scheduleId,
    );

    // Delay execution until after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchScheduleDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: CustomAppBar(title: 'schedule_details'.tr),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final schedule = controller.selectedSchedule.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CachedNetworkImage(
                    imageUrl: schedule.cropImage,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, size: 50),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(schedule.crop, style: Get.textTheme.headlineSmall),
              const SizedBox(height: 10),
              _buildDetailItem('activity_type'.tr, schedule.activityType),
              _buildDetailItem('days'.tr, '${schedule.days}'),
              _buildDetailItem('description'.tr, schedule.description),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    addScheduleBottomSheet();
                  },
                  icon: const Icon(Icons.add),
                  label: Text('add_schedule'.tr),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Get.textTheme.bodyLarge),
          const Divider(),
        ],
      ),
    );
  }
}

void addScheduleBottomSheet() {
  final ScheduleController controller = Get.find<ScheduleController>();

  controller.description.value = controller.selectedSchedule.value.description;
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Add Schedule',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Obx(
                () => InputCardStyle(
                  noHeight: true,
                  child: ListTile(
                    title: const Text('Schedule Date*'),
                    subtitle: Text(
                      '${controller.scheduleDate.value.day}/${controller.scheduleDate.value.month}/${controller.scheduleDate.value.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: Get.context!,
                        initialDate: controller.scheduleDate.value,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        controller.scheduleDate.value = date;
                        if (controller.isRecurring.value) {
                          controller.scheduleEndDate.value = null;
                        }
                      }
                    },
                  ),
                ),
              ),

              Column(
                children: [
                  SizedBox(height: 8),
                  Obx(
                    () => CheckboxListTile(
                      title: const Text('Recurring Task'),
                      value: controller.isRecurring.value,
                      onChanged: (value) =>
                          controller.isRecurring.value = value ?? false,
                    ),
                  ),

                  Obx(() {
                    if (!controller.isRecurring.value) {
                      return const SizedBox();
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        ToggleBar(
                          onTap: (index) {
                            controller.recurrenceType.value = index;
                          },
                          activePageIndex: controller.recurrenceType.value,
                          buttonsList: ["Daily", "Weekly ", "Monthly "],
                        ),
                        const SizedBox(height: 16),

                        // Weekly day selector
                        if (controller.recurrenceType.value == 1)
                          Wrap(
                            spacing: 8,
                            children: List.generate(7, (index) {
                              final day = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ][index];
                              return FilterChip(
                                label: Text(day),
                                selected: controller.selectedDays.contains(
                                  index + 1,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    controller.selectedDays.add(index + 1);
                                  } else {
                                    controller.selectedDays.remove(index + 1);
                                  }
                                },
                              );
                            }),
                          ),

                        // End date picker
                        Obx(
                          () => InputCardStyle(
                            noHeight: true,
                            child: ListTile(
                              title: const Text('Schedule End Date*'),
                              subtitle: Text(
                                controller.scheduleEndDate.value == null
                                    ? 'Not selected'
                                    : '${controller.scheduleEndDate.value!.day}/${controller.scheduleEndDate.value!.month}/${controller.scheduleEndDate.value!.year}',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: Get.context!,
                                  initialDate: controller.scheduleDate.value
                                      .add(const Duration(days: 7)),
                                  firstDate: controller.scheduleDate.value,
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ),
                                );
                                if (date != null) {
                                  controller.scheduleEndDate.value = date;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              SizedBox(height: 8),

              // Description
              InputCardStyle(
                noHeight: true,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description*',
                    border: InputBorder.none,
                  ),
                  initialValue: controller.description.value,
                  maxLines: 2,
                  onChanged: (value) => controller.description.value = value,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter description'
                      : null,
                ),
              ),

              const SizedBox(height: 16),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.addTask();
                        },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : Text('Add Task Schedule'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
