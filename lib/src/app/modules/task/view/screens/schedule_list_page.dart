import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/view/widget/schedule_card.dart';
import 'package:argiot/src/app/modules/task/controller/schedule_controller.dart';
import 'package:argiot/src/app/modules/task/model/schedule_crop.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                    child: DropdownButtonFormField<ScheduleLand>(
                      initialValue: controller.selectedLand.value,

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
                      decoration: const InputDecoration(
                        hintText: 'Land',
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
                      child: DropdownButtonFormField(
                        items: const [],
                        onChanged: null,
                        decoration: const InputDecoration(
                          labelText: 'Select land first',
                          border: InputBorder.none,
                        ),
                      ),
                    );
                  }

                  return InputCardStyle(
                    child: DropdownButtonFormField<ScheduleCrop>(
                      initialValue: controller.selectedCrop.value,

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
                      decoration: const InputDecoration(
                        hintText: 'Crop',
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
              return const Center(child: CircularProgressIndicator());
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
