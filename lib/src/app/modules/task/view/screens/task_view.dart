import 'package:argiot/src/app/modules/near_me/views/widget/land_dropdown.dart';
import 'package:argiot/src/app/modules/task/model/event.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../routes/app_routes.dart';
import '../../../../service/utils/enums.dart';
import '../../../../widgets/loading.dart';
import '../../../../widgets/title_text.dart';
import '../../../forming/view/widget/empty_land_card.dart';
import '../../controller/task_controller.dart';
import '../widget/task_card.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: () => controller.loadTasks(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: TitleText("tasks".tr),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.primaryColor,
                  ),
                  onPressed: () {
                    Get.toNamed(Routes.schedules)?.then((reslut) {
                      if (reslut != null) {
                        controller.loadTasks();
                      }
                    });
                  },
                  child: Text("best_schedule".tr),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => LandDropdown(
                      lands: controller.lands,
                      selectedLand: controller.selectedLand.value,
                      onChanged: (land) => controller.changeLand(land!),
                    ),
                  ),
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
                            controller.fetchTasks();
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
                            controller.taskList();
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
          ),
          Obx(
            () => (!controller.isLoading.value && controller.lands.isEmpty)
                ? EmptyLandCard(
                  padding: EdgeInsets.all(0),
                  view:
                      (!controller.isLoading.value &&
                      controller.lands.isEmpty),
                  refresh: controller.fetchLands,
                )
                : const SizedBox(),
          ),

          Obx(() {
            if (controller.lands.isEmpty) {
              return const SizedBox();
            }
            if (controller.isLoading.value ||
                (controller.isLoading.value && controller.taskGroups.isEmpty)) {
              return const Loading();
            }

            return (controller.isList.value)
                ? Expanded(
                    child: Column(
                      children: [
                        if (controller.errorMessage.value.isNotEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 100),
                              child: Text("no_data_found".tr),
                            ),
                          ),

                        Expanded(
                          child: ListView.builder(
                            itemCount: controller.taskGroups.length,
                            itemBuilder: (context, index) {
                              final group = controller.taskGroups[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      group.date,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ...group.tasks.map(
                                    (task) => TaskCard(task: task),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView(
                      // physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildCalendarSection(),
                        _buildFilterSection(),
                        _buildTaskListSection(),
                      ],
                    ),
                  );
          }),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Get.theme.primaryColor,
      onPressed: () => controller.showAddTaskBottomSheet(),
      child: const Icon(Icons.add),
    ),
  );

  Widget _buildCalendarSection() => Card(
    margin: const EdgeInsets.all(8),
    elevation: 0,
    color: Get.theme.primaryColor.withAlpha(40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(
        () => TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2036, 12, 31),
          focusedDay: controller.focusedDay.value,
          calendarFormat: CalendarFormat.month,
          onPageChanged: (focusedDay) {
            controller.focusedDay.value = focusedDay;
            controller.selectedDay.value = focusedDay;
            controller.refreshData(month: focusedDay.month);
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
              color: Get.theme.primaryColor.withAlpha(130),
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            controller.selectedDay.value = selectedDay;
            controller.focusedDay.value = focusedDay;
          },
          eventLoader: (day) => controller.getEventsForDay(day),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, List<Event> events) {
              if (events.isEmpty) return const SizedBox.shrink();

              return Positioned(
                right: 1,
                bottom: 1,
                child: Row(
                  children: [
                    ...events.map(
                      (event) => Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${event.count}',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: Get.theme.scaffoldBackgroundColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
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
            "${'no_tasks_for_date'.tr} ${DateFormat('d MMMM y').format(selectedDate)}",
          ),
        ),
      );
    }

    return Column(
      children: [
        ...tasks.map(
          (task) => TaskCard(
            key: ValueKey('${task.id}_${controller.selectedDay.value}'),
            task: task,
          ),
        ),
      ],
    );
  });
}
