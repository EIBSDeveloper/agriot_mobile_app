import 'package:argiot/src/app/modules/forming/model/crop_card_model.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
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
                      backgroundImage: NetworkImage(crop.img!),
                      radius: 24,
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
              const Text('Expense: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '₹${crop.expense.toStringAsFixed(2)}  ',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.open_in_new, color: Colors.green.shade700),
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
              const Text('Sales: ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '₹${crop.sales.toStringAsFixed(2)}  ',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.open_in_new, color: Colors.green.shade700),
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
                  backgroundColor: Get.theme.primaryColor.withAlpha(100),
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
