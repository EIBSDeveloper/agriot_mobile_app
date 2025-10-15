import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/task/model/task.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../service/utils/enums.dart';
import '../../../../widgets/input_card_style.dart';
import '../../model/task_types_dropdown_item.dart';
import '../../repostory/task_repository.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.refresh,
    this.trailing = const [],
  });

  final VoidCallback? refresh;
  final Task task;
  final List<Widget> trailing;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late Task task;
  final TaskRepository _taskRepository = TaskRepository();
   AppDataController appDeta = Get.find();

  final statusList = TaskTypes.values
      .whereMap(
        (task) => task == TaskTypes.all
            ? null
            : TaskTypesDropdownItem(task: task, name: getTaskName(task)),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    task = widget.task; // copy from widget
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      Get.toNamed(Routes.taskDetail, arguments: {'taskId': task.id})?.then((
        result,
      ) {
        if (widget.refresh != null) {
          widget.refresh!();
        }
      });
    },
    child: Container(
      margin: const EdgeInsets.only(left: 10, bottom: 8, right: 8),
      constraints: const BoxConstraints(minHeight: 80),
      decoration: AppStyle.decoration.copyWith(
        border: Border(
          left: BorderSide(
            color: task.status != null
                ? getTaskColors(task.status!)
                : Colors.transparent,
            width: 8,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Left section: texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.cropType != null)
                    Text(
                      task.cropType ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  Text(task.activityTypeName ?? ''),
                  const SizedBox(height: 4),

                  // if (task.description.isNotEmpty) ...[
                  //   const SizedBox(height: 2),
                  //   Text(
                  //     task.description,
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: Theme.of(context).textTheme.bodySmall,
                  //   ),
                  // ],
                  if (Get.mediaQuery.size.width <= 600) _buildStatus(),
                ],
              ),
            ),
            if (Get.mediaQuery.size.width > 600)
              Expanded(child: _buildStatus()),

            /// Right section: trailing widgets
            if (widget.trailing.isNotEmpty) ...[
              const SizedBox(width: 8),
              Row(mainAxisSize: MainAxisSize.min, children: widget.trailing),
            ],
          ],
        ),
      ),
    ),
  );
  Widget _buildStatus() {
    bool isEditable = false;

    if (task.taskDate != null) {
      final taskDate = DateTime(
        task.taskDate!.year,
        task.taskDate!.month,
        task.taskDate!.day,
      );
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      isEditable = taskDate.isAtSameMomentAs(todayDate);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(appDeta.permission.value?.schedule?.edit != 0)
          Expanded(
            child: InputCardStyle(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Tooltip(
                message: !isEditable
                    ? 'cannot_change_status_past_tasks'.tr
                    : '',
                child: Opacity(
                  opacity: !isEditable ? 0.6 : 1.0,
                  child: IgnorePointer(
                    ignoring: !isEditable,
                    child: DropdownButtonFormField<TaskTypes>(
                      initialValue: task.status,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      decoration: InputDecoration(
                        labelText: "status".tr,
                        border: InputBorder.none,

                        enabled: !isEditable,
                      ),
                      items: statusList
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.task,
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  color: getTaskColors(item.task),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      // keep onChanged null when disabled for form semantics
                      onChanged: !isEditable
                          ? null
                          : (value) async {
                              if (value != null) {
                                setState(() {
                                  task = task.copyWith(status: value);
                                });
                                await _taskRepository.statusUpdate(
                                  id: task.id,
                                  scheduleStatus: getTaskId(
                                    task.status ?? TaskTypes.completed,
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
