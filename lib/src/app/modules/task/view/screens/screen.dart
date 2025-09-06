// lib/app/modules/task/views/task_view.dart
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../routes/app_routes.dart';
import '../../../../widgets/title_text.dart';
import '../../../../widgets/toggle_bar.dart';
import '../../../near_me/views/widget/widgets.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';

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
                      Get.toNamed('/schedules')?.then((reslut) {
                        if (reslut != null) {
                          controller.loadTasks();
                        }
                      });
                    },
                    child: const Text("Best schedule"),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => LandDropdown(
                        lands: controller.lands,
                        selectedLand: controller.selectedLand.value,
                        onChanged: (land) => controller.changeLand(land!),
                      )),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),

                    child: Obx(() => Row(
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
                              borderRadius: const BorderRadius.only(
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
                      )),
                  ),
                ],
              ),
            ),
            Obx(() {
              if (controller.isLoading.value ||
                  (controller.isLoading.value &&
                      controller.taskGroups.isEmpty)) {
                return const Center(child: CircularProgressIndicator());
              }

              return (controller.isList.value)
                  ? Expanded(
                      child: Column(
                        children: [
                          if (controller.errorMessage.value.isNotEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 100),
                                child: Text("No data found"),
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
                                        '${group.day}, ${group.date}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    ...group.tasks.map(
                                      (task) => _buildTaskCard(task),
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
        onPressed: () => _showAddTaskBottomSheet(),
        child: const Icon(Icons.add),
      ),
    );

  Widget _buildTaskCard(Task tas) {
    Task task = tas;
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.taskDetail, arguments: {'taskId': task.id});
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.grey.withAlpha(30), //rgb(226,237,201)
        elevation: 0,
        child: ListTile(
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
              //   onPressed: () => _showEditTaskBottomSheet(task.id),
              // ),
              IconButton(
                icon: Icon(Icons.delete, color: Get.theme.primaryColor),
                onPressed: () => controller.deleteTask(task.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskBottomSheet() {
    controller.resetForm();
    showTaskFormBottomSheet(isEditing: false);
  }

  void showTaskFormBottomSheet({bool isEditing = false, int? taskId}) {
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
                const SizedBox(height: 16),
                Text(
                  isEditing ? 'Edit Task' : 'Add New Task',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Crop Type Dropdown
                Obx(() => MyDropdown(
                    items: controller.crop,
                    selectedItem: controller.selectedCropType.value,
                    onChanged: (land) => controller.changeCrop(land!),
                    label: 'Crop*',
                    // disable: isEditing,
                  )),
                const SizedBox(height: 8),
                Obx(() => MyDropdown<ActivityModel>(
                    items: controller.activity,
                    selectedItem: controller.selectedActivityType.value,
                    onChanged: (land) => controller.changeActivity(land!),
                    label: 'Activity type *',
                  )),
                const SizedBox(height: 8),
                // Schedule Date
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(137, 221, 234, 234),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
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
                if (!isEditing)
                  Column(
                    children: [
                      const SizedBox(height: 8),
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
                                        controller.selectedDays.remove(
                                          index + 1,
                                        );
                                      }
                                    },
                                  );
                                }),
                              ),

                            // End date picker
                            Obx(
                              () => Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        137,
                                        221,
                                        234,
                                        234,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      title: const Text('Schedule End Date*'),
                                      subtitle: Text(
                                        controller.scheduleEndDate.value == null
                                            ? 'Not selected'
                                            : '${controller.scheduleEndDate.value!.day}/${controller.scheduleEndDate.value!.month}/${controller.scheduleEndDate.value!.year}',
                                      ),
                                      trailing: const Icon(
                                        Icons.calendar_today,
                                      ),
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: Get.context!,
                                          initialDate: controller
                                              .scheduleDate
                                              .value
                                              .add(const Duration(days: 7)),
                                          firstDate:
                                              controller.scheduleDate.value,
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 365 * 2),
                                          ),
                                        );
                                        if (date != null) {
                                          controller.scheduleEndDate.value =
                                              date;
                                          controller.endDate.value == true;
                                        }
                                      },
                                    ),
                                  ),

                                  (!controller.endDate.value)
                                      ? const Text(
                                          "Please add End Date",
                                          style: TextStyle(color: Colors.red),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                const SizedBox(height: 8),

                // Description
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(137, 221, 234, 234),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: InputBorder.none,
                    ),
                    maxLines: 2,
                    onChanged: (value) => controller.description.value = value,
                    // validator: (value) => value?.isEmpty ?? true
                    //     ? 'Please enter description'
                    //     : null,
                  ),
                ),

                const SizedBox(height: 16),
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (controller.isRecurring.value) {
                              controller.endDate.value =
                                  (controller.scheduleEndDate.value == null)
                                  ? false
                                  : true;
                              if (!controller.endDate.value) {
                                return;
                              }
                            }
                            if (isEditing) {
                              controller.editTask(taskId!);
                            } else {
                              controller.addTask();
                            }
                          },
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : Text(isEditing ? 'Update Task' : 'Add Task'),
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

  Widget _buildCalendarSection() => Card(
      margin: const EdgeInsets.all(8),
      elevation: 0,
      color: Get.theme.primaryColor.withAlpha(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Obx(() => TableCalendar(
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
          selectedDayPredicate: (day) => isSameDay(day, controller.selectedDay.value),

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
            markerBuilder: (context, date, List<Event> events) {
              if (events.isEmpty) return const SizedBox.shrink();

              return Positioned(
                right: 1,
                bottom: 1,
                child: Row(
                  children: [
                    ...events.map((e) => Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Get.theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${events[0].tasks.length}',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: Get.theme.scaffoldBackgroundColor,
                            fontSize: 10,
                          ),
                        ),
                      )),
                  ],
                ),
              );
            },
          ),
        )),
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
            _buildFilterChip('Cancelled', 'cancelled'),
            _buildFilterChip('Pending', 'pending'),
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
// lib/widgets/my_dropdown.dart

abstract class NamedItem {
  int get id;
  String get name;
}

class MyDropdown<T extends NamedItem> extends StatelessWidget {

  final List<T> items;
  final String label;
  final bool disabled;
  final T? selectedItem;
  final void Function(T?) onChanged;
  final String? hintText;
  final EdgeInsetsGeometry? padding;
  final InputBorder? border;

  const MyDropdown({
    super.key,

    required this.items,
    required this.label,
    this.disabled = false,
    required this.selectedItem,
    required this.onChanged,
    this.hintText,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) => InputCardStyle(
      // padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        key: key,
        value: selectedItem,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        hint: hintText != null ? Text(hintText!) : null,
        items: items.map((T item) => DropdownMenuItem<T>(
            value: item,
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: disabled ? Colors.grey : null),
            ),
          )).toList(),
        onChanged: disabled ? null : onChanged,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: disabled ? Colors.grey : null),
        validator: (value) {
          if (value == null) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
}
