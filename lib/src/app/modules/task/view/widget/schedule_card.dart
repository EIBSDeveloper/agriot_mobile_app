import 'package:argiot/src/app/modules/task/model/schedule.dart';
import 'package:argiot/src/app/modules/task/controller/schedule_controller.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    required this.schedule,
    required this.controller,
    super.key,
  });
  final Schedule schedule;

  final ScheduleController controller;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    elevation: 1,
    child: ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: schedule.cropImage,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Container(width: 50, height: 50, color: Colors.grey[300]),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
      title: TitleText(schedule.crop),
      subtitle: Text(
        schedule.activityType,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Card(
        color: Get.theme.primaryColor,
        child: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.add),
          onPressed: () async {
            controller.setParameters(
              lId: schedule.cropId,
              cId: schedule.cropId,
              sId: schedule.id,
            );

            // Delay execution until after the first build

            await controller.fetchScheduleDetails();
            controller.addScheduleBottomSheet();
          },
        ),
      ),
      onTap: () {
        Get.toNamed(
          '/schedule-details',
          arguments: {
            'landId': schedule.cropId,
            'cropId': schedule.cropId,
            'scheduleId': schedule.id,
          },
        );
      },
    ),
  );
}
