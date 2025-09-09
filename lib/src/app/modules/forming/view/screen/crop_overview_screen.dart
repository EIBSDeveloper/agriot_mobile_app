import 'package:argiot/src/app/modules/dashboad/view/widgets/bi_pie_chart.dart';
import 'package:argiot/src/app/modules/forming/controller/crop_details_controller.dart';
import 'package:argiot/src/app/modules/forming/model/crop_overview.dart';
import 'package:argiot/src/app/modules/forming/model/schedule.dart';
import 'package:argiot/src/app/modules/forming/model/my_crop_details.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/task/model/task.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../guideline/model/guideline.dart';
import '../../../../routes/app_routes.dart';
import '../../../guideline/model/guideline_category.dart';
import '../../../guideline/view/widget/guideline_card.dart';

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
              const SizedBox(height: 10),
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
      return const Center(child: Text('No crop details available'));
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
        onTap: (){
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
        
                  backgroundImage: NetworkImage(details!.imageUrl!),
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
                    Text(details.land!.name),
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
                arguments: {'landId': landId, 'cropId': cropId},
              )?.then((rturn) {
                if (rturn) {
                  controller.fetchCropDetails(landId, cropId);
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
          const TitleText('Crop Details'),
          const SizedBox(height: 10),
          _buildDetailRow('Crop Type', details!.cropType!.name),
          _buildDetailRow('Harvest Frequency', details.harvestingType!.name),
          _buildDetailRow('Plantation Date', details.plantationDate.toString()),
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
                Column(
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
            itemBuilder: (context, index) {
              final guideline = overview.guidelines[index];

              return SizedBox(
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GuidelineCard(
                    guideline: Guideline(
                      id: guideline.id,
                      name: guideline.name,
                      guidelinestype: guideline.description,
                      guidelinescategory: GuidelineCategory(
                        name: guideline.description,
                        id: 1,
                      ),
                      description: guideline.description,
                      status: 0,
                      mediaType: guideline.mediaType,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildTasksSection(CropOverview overview) {
    if (overview.schedules.isEmpty) return const SizedBox();

    // Group schedules by date
    final schedulesByDate = <String, List<Schedule>>{};
    for (final schedule in overview.schedules) {
      final date = schedule.startDate;
      schedulesByDate.putIfAbsent(date, () => []).add(schedule);
    }

    return Column(
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
                          ...group.tasks.map((task) => _buildTaskCard(task)),
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
        // ...schedulesByDate.entries.map((entry) {
        //   return Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         entry.key,
        //         style: Get.textTheme.titleMedium!.copyWith(
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       ...entry.value.map((schedule) {
        //         Task task = Task(
        //           cropImage: overview.crop.imageUrl!,
        //           cropType: overview.crop.cropType!,
        //           description: schedule.status,
        //           id: schedule.id,
        //         );
        //         return _buildTaskCard(task);
        //       }),
        //     ],
        //   );
        // }),
      ],
    );
  }

  Widget _buildTaskCard(Task task) => InkWell(
    onTap: () {
      Get.toNamed(Routes.taskDetail, arguments: {'taskId': task.id});
    },
    child: Card(
      margin: const EdgeInsets.only(left: 10, bottom: 8),
      color: Colors.grey.withAlpha(30), //rgb(226,237,201)
      elevation: 0,
      child: ListTile(
        // leading: Container(
        //   width: 8,
        //   height: 40,
        //   decoration: BoxDecoration(
        //     color: Colors.green,
        //     borderRadius: BorderRadius.circular(4),
        //   ),
        // ),
        title: Text(task.cropType),
        subtitle: Text(
          task.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // IconButton(
            //   icon: Icon(Icons.edit, color: Get.theme.primaryColor),
            //   onPressed: () {
            //     // _showEditTaskBottomSheet(task.id);
            //   },
            // ),
            // IconButton(
            //   icon: Icon(Icons.delete, color: Get.theme.primaryColor),
            //   onPressed: () {
            //     controller.deleteTask(task.id);
            //   },
            // ),
          ],
        ),
      ),
    ),
  );

  Widget _buildCalendarSection() => Card(
    // margin: const EdgeInsets.all(8),
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
          // Instead of selectedDay, use selectedDayPredicate:
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
              color: Get.theme.primaryColor.withOpacity(0.3),
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
          _buildFilterChip('All', 'all'),
          _buildFilterChip('Completed', 'completed'),
          _buildFilterChip('Waiting', 'waiting'),
          // _buildFilterChip('Cancelled', 'cancelled'),
          // _buildFilterChip('Pending', 'pending'),
          // _buildFilterChip('In Progress', 'in_progress'),
        ],
      ),
    ),
  );

  Widget _buildFilterChip(String label, String value) => Obx(() {
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
        ...tasks.map((data) {
          Task task = Task(
            cropImage: "",
            cropType: data.activityTypeName,
            description: data.description,
            id: data.taskId,
          );
          return _buildTaskCard(task);
        }),
      ],
    );
  });
}
