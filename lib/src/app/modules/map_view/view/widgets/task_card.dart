import 'package:argiot/src/app/modules/task/model/task.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.refresh,
    this.trailing = const [],
  });

  final VoidCallback refresh;
  final Task task;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      Get.toNamed(Routes.taskDetail, arguments: {'taskId': task.id})?.then((
        result,
      ) {
        refresh();
      });
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

      decoration: AppStyle.decoration.copyWith(
        border: const Border(
          left: BorderSide(
            color: Colors.red,
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
                  Text(
                    task.cropType,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.status ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),

            /// Right section: trailing widgets
            if (trailing.isNotEmpty) ...[
              const SizedBox(width: 8),
              Row(mainAxisSize: MainAxisSize.min, children: trailing),
            ],
          ],
        ),
      ),
    ),
  );
}
