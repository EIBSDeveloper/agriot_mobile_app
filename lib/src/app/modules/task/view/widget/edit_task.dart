import 'package:argiot/src/app/modules/task/model/activity_model.dart';
import 'package:argiot/src/app/modules/task/model/my_dropdown.dart';
import 'package:argiot/src/app/modules/task/controller/task_details_controller.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../dashboad/view/widgets/buttom_sheet_scroll_button.dart';

class EditTask extends GetView<TaskDetailsController> {
  const EditTask({super.key});

  @override
  Widget build(BuildContext context) {
    controller.prepareEditFields();
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
                'Edit Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Activity Dropdown
              Obx(
                () => MyDropdown<ActivityModel>(
                  items: controller.activity,
                  selectedItem: controller.selectedActivityType.value,
                  onChanged: (activity) =>
                      controller.selectedActivityType.value = activity!,
                  label: 'Activity type*',
                ),
              ),
              const SizedBox(height: 8),

              // Schedule Date
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
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Description
              InputCardStyle(
                noHeight: true,
                child: TextFormField(
                  initialValue: controller.description.value,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                  onChanged: (value) => controller.description.value = value,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter description'
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Update Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoadingEdit.value
                      ? null
                      : () => controller.updateTask(
                          controller.task.value!.scheduleId,
                        ),
                  child: controller.isLoadingEdit.value
                      ? const CircularProgressIndicator()
                      : const Text('Update Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
