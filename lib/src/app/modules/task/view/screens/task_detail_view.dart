// lib/app/modules/task/models/task_model.dart

import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/task/view/screens/screen.dart';
import 'package:argiot/src/app/modules/task/view/screens/task_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/model.dart';

class TaskDetailView extends GetView<TaskDetailsController> {
  const TaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Task Details',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => _confirmDeleteTask(),
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value ) {
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
              _buildSectionHeader('Land Information'),
              _buildDetailItem('Land Name', task.myLand.name),
              const SizedBox(height: 16),

              _buildSectionHeader('Crop Information'),
              _buildDetailItem('Crop Name', task.myCrop.name),
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
              _buildDetailItem('Status', task.scheduleStatus.name),
              _buildDetailItem('Description', task.description),
              if (task.comment.isNotEmpty)
                _buildDetailItem('Comment', task.comment),
              const SizedBox(height: 16),

              _buildSectionHeader('Expenses'),
              _buildDetailItem('Total Expenses', '${task.totalExpenseAmount}'),
              const SizedBox(height: 24),

              _buildActionButtons(),
                  const SizedBox(height: 200),
            ],
          ),
        );
      }),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        onPressed: _showEditTaskSheet,
        child: const Icon(Icons.edit),
      ),
    );
  }

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
                Obx(() {
                  return MyDropdown<ActivityModel>(
                    items: controller
                        .activity, // Make sure you have activities list
                    selectedItem: controller.selectedActivityType.value,
                    onChanged: (activity) =>
                        controller.selectedActivityType.value = activity!,
                    label: 'Activity type*',
                  );
                }),
                const SizedBox(height: 8),

                // Schedule Date
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(137, 221, 234, 234),
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                        : () =>
                              controller.updateTask(controller.task.value!.scheduleId),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Get.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Get.theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
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
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (controller.task.value?.status == 0)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showAddCommentDialog(),
              child: const Text('Add Comment'),
            ),
          ),
        const SizedBox(height: 8),
        if (controller.task.value?.status == 0)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor:Get.theme.primaryColor),
              onPressed: () {
                controller.markTaskCompleted();
              },
              child: const Text('Mark as Completed'),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showAddCommentDialog() {
    final commentController = TextEditingController(
      text: controller.task.value?.comment ?? '',
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
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
            SizedBox(height: 16),
            const Text(
              'Add Comment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your comment...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.trim().isNotEmpty) {
                      controller.addComment(commentController.text.trim());
                      Get.back();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

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
} // lib/app/modules/task/controllers/task_controller.dart
