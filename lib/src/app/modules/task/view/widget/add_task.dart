// lib/app/modules/task/views/task_view.dart

import 'package:argiot/src/app/modules/task/controller/task_controller.dart';
import 'package:argiot/src/app/modules/task/model/activity_model.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/widgets/toggle_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTask extends GetView<TaskController> {
  final bool isEditing;
  final int taskId;
  const AddTask({super.key, this.isEditing = false, this.taskId = 0});

  @override
  Widget build(BuildContext context) => Container(
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Crop Type Dropdown
            Obx(
              () => MyDropdown(
                items: controller.crop,
                selectedItem: controller.selectedCropType.value,
                onChanged: (land) => controller.changeCrop(land!),
                label: 'Crop*',
                // disable: isEditing,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => MyDropdown<ActivityModel>(
                items: controller.activity,
                selectedItem: controller.selectedActivityType.value,
                onChanged: (land) => controller.changeActivity(land!),
                label: 'Activity type *',
              ),
            ),
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
                                    controller.selectedDays.remove(index + 1);
                                  }
                                },
                              );
                            }),
                          ),

                        // End date picker
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      controller.endDate.value = true;
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: InputBorder.none,
                ),
                maxLines: 2,
                onChanged: (value) => controller.description.value = value,
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
                          controller.editTask(taskId);
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
  );
}
