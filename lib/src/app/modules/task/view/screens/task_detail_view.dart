// lib/app/modules/task/models/task_model.dart

import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/task/view/screens/screen.dart';
import 'package:argiot/src/app/modules/task/view/screens/task_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/input_card_style.dart';
import '../../model/model.dart';

class TaskDetailView extends GetView<TaskDetailsController> {
  const TaskDetailView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBar(
        title: 'Task Details',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => _confirmDeleteTask(),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                ElevatedButton(
                  onPressed: controller.fetchTaskDetails,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final task = controller.task.value;
        if (task == null) {
          return const Center(child: Text('No task details available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildSectionHeader('Land Information'),

              // const SizedBox(height: 16),
              _buildSectionHeader('Crop Information'),
              _buildDetailItem('Crop Name', task.myCrop.name),
              _buildDetailItem('Land Name', task.myLand.name),
              if (task.myCrop.cropImg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.network(task.myCrop.cropImg, height: 150),
                ),
              const SizedBox(height: 16),

              _buildSectionHeader('Task Details'),
              _buildDetailItem('Activity Type', task.scheduleActivityType.name),
              // _buildDetailItem('Start Date', task.startDate),
              _buildDetailItem('Date', task.endDate),
              // _buildDetailItem('Status', task.scheduleStatus.name),
              _buildStatus('Status'),
              _buildDetailItem('Description', task.description),
              if (task.comment.isNotEmpty)
                _buildDetailItem('Comment', task.comment),
              const SizedBox(height: 16),

              // _buildSectionHeader('Expenses'),
              // _buildDetailItem('Total Expenses', '${task.totalExpenseAmount}'),
              const SizedBox(height: 24),

              _buildActionButtons(),
              const SizedBox(height: 200),
            ],
          ),
        );
      }),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Get.theme.primaryColor,
            onPressed: _showEditTaskSheet,
            child: const Icon(Icons.message),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Get.theme.primaryColor,
            onPressed: _showEditTaskSheet,
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );

  void _showEditTaskSheet() {
    controller.prepareEditFields();

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
                const Text(
                  'Edit Task',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Crop Dropdown
                // Obx(() {
                //   return MyDropdown<CropModel>(
                //     items: controller
                //         .crop, // Make sure you have crops list in controller
                //     selectedItem: controller.selectedCropType.value,
                //     onChanged: (crop) => controller.selectedCropType.value = crop!,
                //     label: 'Crop*',
                //   );
                // }),
                // const SizedBox(height: 8),

                // Activity Dropdown
                Obx(() => MyDropdown<ActivityModel>(
                    items: controller
                        .activity, // Make sure you have activities list
                    selectedItem: controller.selectedActivityType.value,
                    onChanged: (activity) =>
                        controller.selectedActivityType.value = activity!,
                    label: 'Activity type*',
                  )),
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
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
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
                      labelText: 'Description*',
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
      ),

      isScrollControlled: true,
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Get.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Get.theme.primaryColor,
        ),
      ),
    );

  Widget _buildDetailItem(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: Get.textTheme.bodyMedium)),
        ],
      ),
    );

  Widget _buildStatus(String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InputCardStyle(
              child: DropdownButtonFormField<int>(
                value: controller.selectedValue.value,
                decoration: const InputDecoration(
                  hintText: "Status",
                  border: InputBorder.none
                ),
                items: controller.statusList.map((item) => DropdownMenuItem<int>(
                    value: item["value"],
                    child: Text(item["name"]),
                  )).toList(),
                onChanged: (value) {
                  controller.selectedValue.value = value!;
                  // setState(() {
                  //   selectedValue = value;
                  // });
                },
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildActionButtons() => Column(
      children: [
        // if (controller.task.value?.status == 0)
        //   SizedBox(
        //     width: double.infinity,
        //     child: ElevatedButton(
        //       onPressed: () => _showAddCommentDialog(),
        //       child: const Text('Add Comment'),
        //     ),
        //   ),
        // const SizedBox(height: 10),
        const SizedBox(height: 10),
        Obx(() => (controller.task.value?.scheduleStatus.id !=
                  controller.selectedValue.value)
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.primaryColor,
                    ),
                    onPressed: () {
                      controller.markTaskCompleted();
                    },
                    child: const Text('Update'),
                  ),
                )
              : const SizedBox()),
        const SizedBox(height: 8),
      ],
    );

  void _confirmDeleteTask() {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.deleteTask();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
