
import 'package:argiot/src/app/modules/task/controller/schedule_controller.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/title_text.dart';


class ScheduleDetailsPage extends StatefulWidget {
  const ScheduleDetailsPage({
    required this.landId,
    required this.cropId,
    required this.scheduleId,
    super.key,
  });
  final int landId;
  final int cropId;
  final int scheduleId;

  @override
  State<ScheduleDetailsPage> createState() => _ScheduleDetailsPageState();
}

class _ScheduleDetailsPageState extends State<ScheduleDetailsPage> {
  final ScheduleController controller = Get.find<ScheduleController>();

  @override
  void initState() {
    super.initState();
    controller.setParameters(
      lId: widget.landId,
      cId: widget.cropId,
      sId: widget.scheduleId,
    );

    // Delay execution until after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchScheduleDetails();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'schedule_details'.tr),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final schedule = controller.selectedSchedule.value;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: schedule.cropImage,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TitleText(schedule.crop),
            const SizedBox(height: 10),
            _buildDetailItem('activity_type'.tr, schedule.activityType),
            _buildDetailItem('days'.tr, '${schedule.days}'),
            _buildDetailItem('description'.tr, schedule.description),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: controller.addScheduleBottomSheet,
                icon: const Icon(Icons.add),
                label: Text('add_schedule'.tr),
              ),
            ),
          ],
        ),
      );
    }),
  );

  Widget _buildDetailItem(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Get.textTheme.bodyLarge),
        const Divider(),
      ],
    ),
  );
}
