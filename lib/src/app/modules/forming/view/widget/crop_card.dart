import 'package:argiot/src/app/modules/forming/model/crop_card_model.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';

class CropCard extends StatelessWidget {
  final CropCardModel crop;

  const CropCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    elevation: 1,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              crop.img != null
                  ? CircleAvatar(
                      radius: 24,
                      backgroundImage: CachedNetworkImageProvider(crop.img!),
                    )
                  : const CircleAvatar(radius: 24, child: Icon(Icons.grass)),
              const SizedBox(width: 12),
              Expanded(child: TitleText(crop.name)),
            ],
          ),

          const SizedBox(height: 12),

          // Expense
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Expense: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  // Get.toNamed(...) if needed
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '₹${crop.expense.toStringAsFixed(2)}  ',
                        style: TextStyle(
                          color: Get.theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.open_in_new, color: Get.theme.primaryColor),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Sales
          Row(
            children: [
              const Text(
                'Sales: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.sales, arguments: {"crop_id": crop.id});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '₹${crop.sales.toStringAsFixed(2)}  ',
                        style: TextStyle(
                          color: Get.theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.open_in_new, color: Get.theme.primaryColor),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tasks and Progress
          Row(
            children: [
              Text(
                'Task: ${crop.completedScheduleCount}/${crop.totalScheduleCount}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LinearProgressIndicator(
                  backgroundColor: Get.theme.primaryColor.withAlpha(50),
                  color: Get.theme.primaryColor,
                  value: crop.totalScheduleCount > 0
                      ? crop.completedScheduleCount / crop.totalScheduleCount
                      : 0,
                ),
              ),
            ],
          ), 
        ],
      ),
    ),
  );

  
}
