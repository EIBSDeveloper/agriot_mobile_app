import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/controller/schedule_controller.dart';
import 'package:argiot/src/app/modules/task/model/schedule_crop.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';
import 'package:argiot/src/app/modules/task/view/widget/schedule_card.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';

class ScheduleListPage extends GetView<ScheduleController> {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'schedules'.tr),
    body: Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => InputCardStyle(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<ScheduleLand>(
                      initialValue: controller.selectedLand.value,
                      padding: EdgeInsets.zero,
                      items: controller.lands
                          .map(
                            (ScheduleLand land) =>
                                DropdownMenuItem<ScheduleLand>(
                                  value: land,
                                  child: Text(land.name),
                                ),
                          )
                          .toList(),
                      onChanged: (ScheduleLand? land) {
                        controller.selectLand(land);
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                      decoration: InputDecoration(
                        labelText: 'land'.tr,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() {
                  final crops = controller.cropsForSelectedLand;

                  if (controller.selectedLand.value == null) {
                    return InputCardStyle(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonFormField(
                        items: const [],
                        padding: EdgeInsets.zero,
                        onChanged: null,
                        decoration: InputDecoration(
                          labelText: 'select_land_first'.tr,
                          border: InputBorder.none,
                        ),
                      ),
                    );
                  }

                  return InputCardStyle(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<ScheduleCrop>(
                      initialValue: controller.selectedCrop.value,
                      padding: EdgeInsets.zero,
                      items: crops
                          .map(
                            (ScheduleCrop crop) =>
                                DropdownMenuItem<ScheduleCrop>(
                                  value: crop,
                                  child: Text(crop.name),
                                ),
                          )
                          .toList(),
                      onChanged: (ScheduleCrop? crop) {
                        controller.selectCrop(crop);
                      },
                      icon: const Icon(Icons.keyboard_arrow_down),
                      decoration: InputDecoration(
                        labelText: 'crop'.tr,
                        border: InputBorder.none,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Loading();
            }

            if (controller.filteredSchedules.isEmpty) {
              return Center(child: Text('no_schedules_found'.tr));
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchSchedules(),
              child: ListView.builder(
                itemCount: controller.filteredSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = controller.filteredSchedules[index];
                  return ScheduleCard(
                    schedule: schedule,
                    controller: controller,
                  );
                },
              ),
            );
          }),
        ),
      ],
    ),
  );
}
