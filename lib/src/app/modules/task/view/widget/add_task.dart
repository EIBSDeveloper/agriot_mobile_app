// lib/app/modules/task/views/task_view.dart

import 'package:argiot/src/app/modules/task/controller/task_controller.dart';
import 'package:argiot/src/app/modules/task/model/activity_model.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/app/widgets/toggle_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';
import '../../../dashboad/view/widgets/buttom_sheet_scroll_button.dart';

class AddTask extends GetView<TaskController> {

  final int taskId;
  const AddTask({super.key,  this.taskId = 0});

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
            const ButtomSheetScrollButton(),
            Text(
              'add_new_task'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Crop Type Dropdown
            Obx(
              () => MyDropdown(
                items: controller.crop,
                selectedItem: controller.selectedCropType.value,
                onChanged: (land) => controller.changeCrop(land!),
                label: "${'crop'.tr} *",
                // disable: isEditing,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => MyDropdown<ActivityModel>(
                items: controller.activity,
                selectedItem: controller.selectedActivityType.value,
                onChanged: (land) => controller.changeActivity(land!),
                label: "${'activity_type'.tr} *",
              ),
            ),
            const SizedBox(height: 8),
            // Schedule Date
            Obx(
              () => InputCardStyle(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  title: Text("${'schedule_date'.tr} *"),
                  subtitle: Text(
                    '${controller.scheduleDate.value.day}/${controller.scheduleDate.value.month}/${controller.scheduleDate.value.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.zero,
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
                  const SizedBox(height: 8),
                  Obx(
                    () => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'recurring_task'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                          buttonsList: ["daily".tr, "weekly".tr, "monthly".tr],
                        ),
                        const SizedBox(height: 8),

                        // Weekly day selector
                        if (controller.recurrenceType.value == 1)
                          Wrap(
                            spacing: 8,
                            children: List.generate(7, (index) {
                              final day = [
                                'mon'.tr,
                                'tue'.tr,
                                'wed'.tr,
                                'thu'.tr,
                                'fri'.tr,
                                'sat'.tr,
                                'sun'.tr,
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
                        if (controller.recurrenceType.value != 2)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InputCardStyle(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: ListTile(
                                  title: Text("${'schedule_end_date'.tr} *"),
                                  contentPadding: EdgeInsets.zero,
                                  subtitle: Text(
                                    controller.scheduleEndDate.value == null
                                        ? 'not_selected'.tr
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
                                  ? Text(
                                      "please_add_end_date".tr,
                                      style: const TextStyle(color: Colors.red),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                      ],
                    );
                  }),
                ],
              ),
            const SizedBox(height: 8),

            // Description
            InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'description'.tr,
                  border: InputBorder.none,
                ),
                maxLines: 3,
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
                  controller.addTask();
               
                      },
                child: controller.isLoading.value
                    ? const Loading(size: 50)
                    : Text( 'add_task'.tr),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
