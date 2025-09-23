import 'package:argiot/src/app/modules/dashboad/view/widgets/buttom_sheet_scroll_button.dart';
import 'package:argiot/src/app/modules/map_view/controller/land_map_view_controller.dart';
import 'package:argiot/src/app/modules/map_view/model/crop_map_data.dart';
import 'package:argiot/src/app/modules/map_view/view/widgets/task_card.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../service/utils/utils.dart';

class CropDetailsBottomSheet extends GetView<LandMapViewController> {
  final CropMapData crop;
  const CropDetailsBottomSheet({super.key, required this.crop});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxHeight: 600),
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ButtomSheetScrollButton(),
          Row(
            children: [
              if (crop.cropImage != null)
                Image.network(crop.cropImage!, height: 80, width: 80),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TitleText(crop.cropName ?? "Crop"),
                      Text(
                        crop.cropType != null ? "(${crop.cropType})" : "",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Expense: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          Get.toNamed(
                            Routes.cropOverview,
                            arguments: {
                              'landId': controller.selectedLand.value!.id,
                              'cropId': crop.cropId,
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '₹${controller.cropDetails.value!.expense}  ',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.open_in_new,
                                color: Colors.green.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text(
                        'Sales: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          Get.toNamed(
                            Routes.sales,
                            arguments: {"crop_id": crop.cropId},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '₹${controller.cropDetails.value!.sales}  ',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.open_in_new,
                                color: Colors.green.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Divider(height: 1),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${kelvinToCelsius(controller.weatherData.value!.temperature).toStringAsFixed(1)}°C|°F'
                        .tr,
                    style: TextStyle(
                      fontSize: 20,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text("/"),
                const SizedBox(width: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(controller.weatherData.value!.condition.tr),
                ),
                const SizedBox(width: 4),
                const Text("/"),
                const SizedBox(width: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${'humidity_percentage'.tr}${controller.weatherData.value!.humidity.toString()}",
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          if (controller.cropDetails.value!.tasks.isNotEmpty)
            const TitleText("Today task"),
          Obx(
            () => Column(
              children: [
                ...controller.cropDetails.value!.tasks.map(
                  (task) => TaskCard(
                    task: task,
                    refresh: () {
                      controller.fetchLandsAndCropsDetails(crop.cropId!);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
