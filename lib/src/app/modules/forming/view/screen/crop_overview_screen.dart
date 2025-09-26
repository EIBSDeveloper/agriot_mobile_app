import 'package:argiot/src/app/modules/dashboad/view/widgets/bi_pie_chart.dart';
import 'package:argiot/src/app/modules/dashboad/view/widgets/chart_data.dart';
import 'package:argiot/src/app/modules/forming/controller/crop_details_controller.dart';
import 'package:argiot/src/app/modules/forming/model/crop_overview.dart';
import 'package:argiot/src/app/modules/forming/model/my_crop_details.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../core/app_icons.dart';
import '../../../../service/utils/enums.dart';
import '../../../../routes/app_routes.dart';
import '../../../guideline/view/widget/guideline_card.dart';
import '../../../map_view/view/widgets/task_card.dart';

class CropOverviewScreen extends StatefulWidget {
  const CropOverviewScreen({super.key});

  @override
  State<CropOverviewScreen> createState() => _CropOverviewScreenState();
}

class _CropOverviewScreenState extends State<CropOverviewScreen> {
  final CropDetailsController controller = Get.find();
  final int landId = Get.arguments['landId'];

  final int cropId = Get.arguments['cropId'];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    controller.landId.value = landId;
    controller.cropId.value = cropId;
    await controller.fetchCropOverview();
    await controller.loadTasks();
    await controller.fetchCropDetails(landId, cropId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Crop Details', showBackButton: true),
    body: RefreshIndicator(
      onRefresh: () async {
        loadData();
      },
      child: Obx(() {
        if (controller.isOverviewLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.overview.value == null) {
          return const Center(child: Text('No crop data available'));
        }
        final overview = controller.overview.value!;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Info Section
              _buildCropInfoSection(),
              // const SizedBox(height: 10),
              // Statistics Section
              _buildStatisticsSection(overview),
              const SizedBox(height: 10),
              // Guidelines Section
              _buildGuidelinesSection(overview),
              const SizedBox(height: 10),
              // Tasks Section
              _buildTasksSection(overview),
            ],
          ),
        );
      }),
    ),
  );

  Widget _buildCropInfoSection() => Obx(() {
    if (controller.isDetailsLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.details.value == null) {
      return const SizedBox.shrink();
    }

    final crop = controller.details.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crop Info Section
        _buildCropInfo(crop),
        if (controller.isCropExpended.value)
          Column(
            children: [
              _buildCropDetailsSection(crop),

              _buildSurveyDetailsSection(crop),
            ],
          ),
      ],
    );
  });

  Widget _buildCropInfo(MyCropDetails? details) => Stack(
    children: [
      InkWell(
        onTap: () {
          controller.isCropExpended.value = !controller.isCropExpended.value;
        },
        child: Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: details!.imageUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(details.imageUrl!)
                      : null,
                  child: details.imageUrl!.isEmpty
                      ? const Icon(Icons.agriculture, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(
                      '${details.crop!.name} (Day - ${controller.getDaysSincePlantation(details.plantationDate)})',
                    ),
                    InkWell(
                      onTap: () {
                        Get.toNamed(
                          Routes.landDetail,
                          arguments: controller.landId.value,
                          preventDuplicates: true,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(details.land!.name),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        top: 5,
        right: 5,
        child: IconButton(
          icon: Icon(Icons.edit, color: Get.theme.primaryColor),
          onPressed: () =>
              Get.toNamed(
                Routes.addCrop,
                arguments: {
                  'landId': controller.landId.value,
                  'cropId': controller.cropId.value,
                },
              )?.then((rturn) {
                if (rturn) {
                  controller.fetchCropDetails(
                    controller.landId.value,
                    controller.cropId.value,
                  );
                }
              }),
        ),
      ),
      Positioned(
        bottom: 5,
        right: 5,
        child: IconButton(
          onPressed: () {
            controller.isCropExpended.value = !controller.isCropExpended.value;
          },
          iconSize: 30,
          icon: Obx(
            () => Icon(
              !controller.isCropExpended.value
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_up_outlined,
              color: Get.theme.primaryColor,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildCropDetailsSection(MyCropDetails? details) => Card(
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TitleText('Crop Details'),
              const Spacer(),
              InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.landMapView,
                    arguments: {
                      'landId': controller.landId.value,
                      'cropId': controller.cropId.value,
                    },
                  );
                },
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset(AppIcons.map),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDetailRow('Crop Type', details!.cropType!.name),
          _buildDetailRow('Harvest Frequency', details.harvestingType!.name),
          _buildDetailRow('Plantation Date', DateFormat('dd/MM/yyyy').format(details.plantationDate!)),
          _buildDetailRow(
            'Measurement',
            '${details.measurementValue} ${details.measurementUnit!.name}',
          ),
          // _buildDetailRow('Patta Number', '${details.} '),
        ],
      ),
    ),
  );

  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Get.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(flex: 3, child: Text(value, style: Get.textTheme.bodyLarge)),
      ],
    ),
  );

  Widget _buildSurveyDetailsSection(MyCropDetails? details) {
    if (details!.surveyDetails!.isEmpty) return const SizedBox();

    return Card(
      elevation: 1,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

        child: ExpansionTile(
          title: Text('Survey Details (${details.surveyDetails!.length})'),
          children: [
            DataTable(
              columns: [
                const DataColumn(label: Text('Survey No')),
                const DataColumn(label: Text('Area')),
              ],
              rows: details.surveyDetails!
                  .map(
                    (survey) => DataRow(
                      cells: [
                        DataCell(Text(survey.surveyNo!)),
                        DataCell(
                          Text(
                            '${survey.measurementValue} ${survey.measurementUnit}',
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(CropOverview overview) => Card(
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 150,
              width: 200,
              child: BiPieChart(
                chartData: [
                  ChartData(
                    'expenses'.tr,
                    overview.crop.totalExpenses! < 0.0
                        ? 0
                        : overview.crop.totalExpenses!,
                    Colors.amber,
                  ),
                  ChartData(
                    'sales'.tr,
                    overview.crop.totalSales! < 0.0
                        ? 0
                        : overview.crop.totalSales!,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 150, color: Colors.grey),
          Expanded(
            child: Column(
              children: [
                Column(
                  children: [
                    Text('expenses'.tr, style: Get.textTheme.titleMedium),
                    Text(
                      '₹${(overview.crop.totalExpenses ?? 0).toStringAsFixed(0)}k',
                      style: Get.textTheme.headlineSmall?.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    // if (controller.details.value?.crop?.id != null) {
                    Get.toNamed(
                      Routes.sales,
                      arguments: {"crop_id": Get.arguments['cropId']},
                    );
                    // }else{
                    //   warningSuccess("Crop details are loading, please wait..");
                    // }
                  },
                  child: Column(
                    children: [
                      Text('sales'.tr, style: Get.textTheme.titleMedium),
                      Text(
                        '₹${(overview.crop.totalSales ?? 0).toStringAsFixed(0)}k',
                        style: Get.textTheme.headlineSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildGuidelinesSection(CropOverview overview) {
    if (overview.guidelines.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText('guidelines'.tr),

        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: overview.guidelines.length,
            itemBuilder: (context, index) => SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GuidelineCard(
                    guideline:  overview.guidelines[index]
                  ),
                ),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection(CropOverview overview) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TitleText('tasks'.tr),
            ),

            const SizedBox(width: 10),
            Obx(
              () => Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: !(controller.isList.value)
                          ? Get.theme.primaryColor
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Get.theme.primaryColor,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        controller.isList.value = false;
                      },
                      icon: Icon(
                        Icons.calendar_month,
                        color: !(controller.isList.value)
                            ? Colors.white
                            : Get.theme.primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: (controller.isList.value)
                          ? Get.theme.primaryColor
                          : Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      border: Border.all(
                        color: Get.theme.primaryColor,
                        width: 1,
                      ),
                    ),

                    child: IconButton(
                      onPressed: () {
                        controller.isList.value = true;
                      },
                      icon: Icon(
                        Icons.list,
                        color: (controller.isList.value)
                            ? Colors.white
                            : Get.theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        Obx(() {
          if (controller.isLoading.value ||
              (controller.isLoading.value && controller.taskGroups.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          return (controller.isList.value)
              ? Column(
                  children: [
                    if (controller.errorMessage.value.isNotEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text("No data found"),
                        ),
                      ),
                    ...controller.taskGroups.map(
                      (group) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 8,
                            ),
                            child: Text(
                              '${group.day}, ${group.date}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...group.tasks.map(
                            (task) => TaskCard(
                              task: task,
                              refresh: () {
                                controller.loadTasks();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarSection(),
                    _buildFilterSection(),
                    _buildTaskListSection(),
                  ],
                );
        }),
        const SizedBox(height: 180),
      ],
    );

  Widget _buildCalendarSection() => Card(
    elevation: 0,
    color: Get.theme.primaryColor.withAlpha(40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Obx(
      () => Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2036, 12, 31),
          focusedDay: controller.focusedDay.value,
          calendarFormat: CalendarFormat.month,
          onPageChanged: (focusedDay) {
            controller.focusedDay.value = focusedDay;
            controller.selectedDay.value = focusedDay;
            controller.refreshData(month: focusedDay);
          },
      
          selectedDayPredicate: (day) =>
              isSameDay(day, controller.selectedDay.value),

          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: Get.textTheme.titleLarge!,
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: Get.textTheme.bodyMedium!,
            weekendStyle: Get.textTheme.bodyMedium!,
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: Get.textTheme.bodyMedium!,
            defaultTextStyle: Get.textTheme.bodyMedium!,
            selectedTextStyle: Get.textTheme.bodyMedium!.copyWith(
              color: Get.theme.scaffoldBackgroundColor,
            ),
            selectedDecoration: BoxDecoration(
              color: Get.theme.primaryColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Get.theme.primaryColor.withAlpha(150),
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            controller.selectedDay.value = selectedDay;
            controller.focusedDay.value = focusedDay;
          },
          eventLoader: (day) => controller.getEventsForDay(day),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${events.length}',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.scaffoldBackgroundColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Widget _buildFilterSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...TaskTypes.values.map(
            (task) => _buildFilterChip(getTaskName(task), task),
          ),
        ],
      ),
    ),
  );
  Widget _buildFilterChip(String label, TaskTypes value) => Obx(() {
    final isSelected = controller.selectedFilter.value == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => controller.changeFilter(value),
        selectedColor: Get.theme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected
              ? Get.theme.scaffoldBackgroundColor
              : Get.theme.textTheme.bodyMedium?.color,
        ),
      ),
    );
  });

  Widget _buildTaskListSection() => Obx(() {
    final selectedDate = controller.selectedDay.value;
    final tasks = controller.getTasksForDay(selectedDate);

    if (tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Text(
            'No tasks for ${DateFormat('d MMMM y').format(selectedDate)}'.tr,
          ),
        ),
      );
    }

    return Column(
      children: [
        ...tasks.map(
          (task) => TaskCard(
            task: task,
            refresh: () {
              controller.loadTasks();
            },
          ),
        ),
      ],
    );
  });
}
