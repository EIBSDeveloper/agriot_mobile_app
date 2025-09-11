import 'package:argiot/src/app/modules/task/controller/schedule_controller.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/app/widgets/toggle_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../dashboad/view/widgets/buttom_sheet_scroll_button.dart';

class AddSchedule extends StatelessWidget {
  AddSchedule({super.key});
  final ScheduleController controller = Get.find<ScheduleController>();

  @override
  Widget build(BuildContext context) {
    controller.description.value =
        controller.selectedSchedule.value.description;

    return Container(
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
              const Text(
                'Add Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              InputCardStyle(
                noHeight: true,
                child: TextFormField(
                  readOnly: true, // disable keyboard
                  decoration: InputDecoration(
                    labelText: "Schedule Date*",
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      color: Get.theme.primaryColor,
                    ),
                    border: InputBorder.none,
                  ),
                  controller: TextEditingController(
                    text:
                        "${controller.scheduleDate.value.day}/${controller.scheduleDate.value.month}/${controller.scheduleDate.value.year}",
                  ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select schedule date";
                    }
                    return null;
                  },
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: 8),
                  Obx(
                    () => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
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
                          buttonsList: const ["Daily", "Weekly ", "Monthly "],
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
                        InputCardStyle(
                          noHeight: true,
                          child: TextFormField(
                            readOnly: true, // prevent keyboard
                            decoration: InputDecoration(
                              labelText: "Schedule End Date*",
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: Get.theme.primaryColor,
                              ),
                            
                              border: InputBorder.none,
                            ),
                            controller: TextEditingController(
                              text: controller.scheduleEndDate.value == null
                                  ? ""
                                  : "${controller.scheduleEndDate.value!.day}/${controller.scheduleEndDate.value!.month}/${controller.scheduleEndDate.value!.year}",
                            ),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: Get.context!,
                                initialDate: controller.scheduleDate.value.add(
                                  const Duration(days: 7),
                                ),
                                firstDate: controller.scheduleDate.value,
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 2),
                                ),
                              );
                              if (date != null) {
                                controller.scheduleEndDate.value = date;
                              }
                            },
                            validator: (value) {
                              if (controller.scheduleEndDate.value == null) {
                                return "Please select end date";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              InputCardStyle(
                noHeight: true,
                child: TextFormField(
                  decoration: const InputDecoration(
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
                      : controller.addTask,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Add Task Schedule'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
