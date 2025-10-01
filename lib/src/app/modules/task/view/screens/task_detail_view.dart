// lib/app/modules/task/models/task_model.dart

import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/controller/task_details_controller.dart';
import 'package:argiot/src/app/modules/task/view/widget/edit_task.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../service/utils/enums.dart';
import '../../../../widgets/input_card_style.dart';
import '../../../../widgets/title_text.dart';
import '../../../dashboad/view/widgets/buttom_sheet_scroll_button.dart';

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
          icon: Icon(Icons.delete, color: Get.theme.primaryColor),
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

      return RefreshIndicator(
        onRefresh: controller.fetchTaskDetails,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildSectionHeader('Land Information'),
              const TitleText('Crop Information'),
              const SizedBox(height: 16),
              Row(
                children: [
                  task.myCrop.cropImg.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            task.myCrop.cropImg,
                          ),
                          radius: 35,
                        )
                      : const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.grass),
                        ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleText(task.myCrop.name),
                      Text(task.myLand.name),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              const TitleText('Task Details'),
              _buildDetailItem('Activity Type', task.scheduleActivityType.name),

              _buildDetailItem('Date', task.endDate),

              _buildDetailItem('Description', task.description),

              _buildDetailItem('Comment', task.comment),
              _buildStatus('Status'),

              const SizedBox(height: 24),

              _buildActionButtons(),
              const SizedBox(height: 200),
            ],
          ),
        ),
      );
    }),

    floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: null,
          backgroundColor: Get.theme.primaryColor,
          onPressed: _showAddCommentDialog,
          child: const Icon(Icons.message),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: null,
          backgroundColor: Get.theme.primaryColor,
          onPressed: _showEditTaskSheet,
          child: const Icon(Icons.edit),
        ),
      ],
    ),
  );

  void _showEditTaskSheet() {
    Get.bottomSheet(const EditTask(), isScrollControlled: true);
  }

  Widget _buildDetailItem(String label, String value) => (value.isNotEmpty)
      ? Padding(
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
        )
      : const SizedBox.shrink();

  Widget _buildStatus(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: InputCardStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonFormField<TaskTypes>(
              initialValue: controller.selectedValue.value,
              icon: const Icon(Icons.keyboard_arrow_down),
              decoration: const InputDecoration(
                labelText: "Status",
                border: InputBorder.none,
              ),
              items: controller.statusList
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.task,
                      child: Text(
                        item.name,
                        selectionColor: getTaskColors(item.task),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                controller.selectedValue.value = value!;
              },
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildActionButtons() => Obx(
    () =>
        (controller.task.value?.scheduleStatus.id !=
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
        : const SizedBox.shrink(),
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

  void _showAddCommentDialog() {
    final commentController = TextEditingController(
      text: controller.task.value?.comment ?? '',
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ButtomSheetScrollButton(),
            const Text(
              'Add Comment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Enter your comment...',
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
}
