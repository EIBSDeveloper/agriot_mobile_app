import 'package:argiot/src/app/modules/dashboad/view/widgets/bi_pie_chart.dart';
import 'package:argiot/src/app/modules/forming/controller/crop_details_controller.dart';
import 'package:argiot/src/app/modules/forming/view/screen/crop_model.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../../guideline.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../utils.dart';
import '../../../task/model/model.dart';

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
    controller.landId.value = landId;
    controller.cropId.value = cropId;
    controller.fetchCropOverview();
    controller.loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Crop Overview', showBackButton: true),
      body: Obx(() {
        if (controller.isOverviewLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.overview.value == null) {
          return Center(child: Text('No crop data available'));
        }
        final overview = controller.overview.value!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Info Section
              _buildCropInfoSection(overview, cropId),
              SizedBox(height: 10),
              // Statistics Section
              _buildStatisticsSection(overview),
              SizedBox(height: 10),
              // Guidelines Section
              _buildGuidelinesSection(overview),
              SizedBox(height: 10),
              // Tasks Section
              _buildTasksSection(overview),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCropInfoSection(CropOverview overview, int cropId) {
    return InkWell(
      onTap: () => Get.toNamed(
        '/crop-detail',
        arguments: {'landId': landId, 'cropId': cropId},
      ),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(overview.crop.imageUrl ?? ''),
                child: overview.crop.imageUrl == null
                    ? Icon(Icons.agriculture, size: 30)
                    : null,
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(overview.crop.name, style: Get.textTheme.titleLarge),
                  Text(overview.land.name),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(CropOverview overview) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(0),
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
  }

  Widget _buildGuidelinesSection(CropOverview overview) {
    if (overview.guidelines.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText('guidelines'.tr),

        SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: overview.guidelines.length,
            itemBuilder: (context, index) {
              final guideline = overview.guidelines[index];
              var guideline2 = Guideline(
                id: guideline.id,
                name: guideline.name,
                guidelinestype: guideline.description,
                guidelinescategory: null,
                description: guideline.description,
                status: 0,
                mediaType: guideline.mediaType,
              );
              return _buildGuidelineCard(guideline2);
            },
          ),
        ),
      ],
    );
  }

  void _handleGuidelineTap(Guideline guideline) {
    if (guideline.mediaType == 'video' && guideline.videoUrl != null) {
      Get.toNamed('/video-player', arguments: guideline.videoUrl);
    } else if (guideline.mediaType == 'document' &&
        guideline.document != null) {
      Get.toNamed('/document-viewer', arguments: guideline.document);
    } else {
      showError('Unable to open guideline content');
    }
  }

  Widget _buildThumbnail(Guideline guideline) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 238, 238, 238),
            borderRadius: BorderRadius.circular(8),
          ),
          child: guideline.mediaType == 'video'
              ? const Icon(Icons.videocam, size: 40, color: Colors.grey)
              : const Icon(
                  Icons.insert_drive_file,
                  size: 40,
                  color: Colors.grey,
                ),
        ),
        if (guideline.mediaType == 'video')
          const Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
      ],
    );
  }

  Widget _buildGuidelineCard(Guideline guideline) {
    return SizedBox(
      width: 300,
      child: Card(
        color: const Color.fromARGB(255, 242, 240, 232), //rgb(242,240,232)
        elevation: 0,
        margin: const EdgeInsets.only(right: 16),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: InkWell(
            onTap: () => _handleGuidelineTap(guideline),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(guideline),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guideline.guidelinestype,
                        style: Get.textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guideline.description,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksSection(CropOverview overview) {
    if (overview.schedules.isEmpty) return SizedBox();

    // Group schedules by date
    final schedulesByDate = <String, List<Schedule>>{};
    for (final schedule in overview.schedules) {
      final date = schedule.startDate;
      schedulesByDate.putIfAbsent(date, () => []).add(schedule);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 1),
                ),

                child: Obx(() {
                  return Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: !(controller.isList.value)
                              ? Get.theme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
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
                                : Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: (controller.isList.value)
                              ? Get.theme.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
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
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
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
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Text("No data found"),
                          ),
                        ),
                      ...controller.taskGroups.map((group) {
                        return Column(
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
                        );
                      }),
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
          SizedBox(height: 180),
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
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return InkWell(
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
          trailing: Row(
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
  }

  Widget _buildCalendarSection() {
    return Card(
      // margin: const EdgeInsets.all(8),
      elevation: 0,
      color: Get.theme.primaryColor.withAlpha(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Obx(() {
        return TableCalendar(
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
          selectedDayPredicate: (day) {
            return isSameDay(day, controller.selectedDay.value);
          },

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
          eventLoader: (day) {
            return controller.getEventsForDay(day);
          },
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
        );
      }),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
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
  }

  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
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
  }

  Widget _buildTaskListSection() {
    return Obx(() {
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
}
