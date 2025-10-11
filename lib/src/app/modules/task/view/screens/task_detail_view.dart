// lib/app/modules/task/models/task_model.dart

import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/controller/task_details_controller.dart';
import 'package:argiot/src/app/modules/task/view/widget/edit_task.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../service/utils/enums.dart';
import '../../../../widgets/input_card_style.dart';
import '../../../../widgets/loading.dart';
import '../../../../widgets/title_text.dart';
import '../../../dashboad/view/widgets/buttom_sheet_scroll_button.dart';

class TaskDetailView extends GetView<TaskDetailsController> {
  const TaskDetailView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'task_details'.tr,
      showBackButton: true,
      actions: [
        IconButton(
          onPressed: _confirmDeleteTask,
          icon: Icon(Icons.delete, color: Get.theme.primaryColor),
        ),
      ],
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Loading();
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value),
              ElevatedButton(
                onPressed: controller.fetchTaskDetails,
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      final task = controller.task.value;
      if (task == null) {
        return Center(child: Text('no_task_details_available'.tr));
      }

      // 🔹 Local date logic
      DateTime taskDate = DateFormat("dd-MM-yyyy").parse(task.startDate);
      final taskDate1 = DateTime(taskDate.year, taskDate.month, taskDate.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      bool isEditable = taskDate1.isAtSameMomentAs(todayDate);

      return RefreshIndicator(
        onRefresh: controller.fetchTaskDetails,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleText('crop_information'.tr),
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

              TitleText('task_details'.tr),
              _buildDetailItem(
                'activity_type'.tr,
                task.scheduleActivityType.name,
              ),
              _buildDetailItem('date'.tr, task.startDate),
              _buildDetailItem('description'.tr, task.description),
              _buildDetailItem('comment'.tr, task.comment),
              _buildStatus('status'.tr, isEditable: isEditable),

              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 200),
            ],
          ),
        ),
      );
    }),
    floatingActionButton: Obx(() {
      final task = controller.task.value;
      if (task == null) return const SizedBox.shrink();

      DateTime taskDate = DateFormat("dd-MM-yyyy").parse(task.startDate);
      final taskDate1 = DateTime(taskDate.year, taskDate.month, taskDate.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      bool isUpdatable = taskDate1.isBefore(todayDate);

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isUpdatable)
            FloatingActionButton(
              heroTag: "commentBtn",
              backgroundColor: Get.theme.primaryColor,
              onPressed: _showAddCommentDialog,
              child: const Icon(Icons.message),
            ),
          const SizedBox(height: 10),
          if (!isUpdatable)
            FloatingActionButton(
              heroTag: "editBtn",
              backgroundColor: Get.theme.primaryColor,
              onPressed: _showEditTaskSheet,
              child: const Icon(Icons.edit),
            ),
        ],
      );
    }),
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
  Widget _buildStatus(String label, {bool isEditable = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: InputCardStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Tooltip(
              message: !isEditable ? 'cannot_change_status_past_tasks'.tr : '',
              child: IgnorePointer(
                ignoring: !isEditable,
                child: DropdownButtonFormField<TaskTypes>(
                  initialValue: controller.selectedValue.value,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                    enabled: !isEditable,
                  ),
                  items: controller.statusList
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.task,
                          child: Text(
                            item.name,
                            style: TextStyle(color: getTaskColors(item.task)),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: !isEditable
                      ? null // disable if past date
                      : (value) {
                          controller.selectedValue.value = value!;
                        },
                ),
              ),
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
              child: Text('update'.tr),
            ),
          )
        : const SizedBox.shrink(),
  );

  void _confirmDeleteTask() {
    Get.dialog(
      AlertDialog(
        title: Text('confirm_delete'.tr),
        content: Text('delete_task_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              controller.deleteTask();
            },
            child: Text('delete'.tr),
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
            Text(
              'add_comment'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'enter_comment'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('cancel'.tr),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.trim().isNotEmpty) {
                      controller.addComment(commentController.text.trim());
                      Get.back();
                    }
                  },
                  child: Text('save'.tr),
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
