
import 'package:argiot/src/app/modules/task/model/task.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
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
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.grey.withAlpha(30), //rgb(226,237,201)
      elevation: 0,
      child: ListTile(
        title: Text(task.cropType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.status ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: trailing),
      ),
    ),
  );
}
