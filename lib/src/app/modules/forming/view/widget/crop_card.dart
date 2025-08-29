import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/land_detail_model.dart';

class CropCard extends StatelessWidget {
  final CropCardModel crop;

  const CropCard({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: crop.img != null
            ? CircleAvatar(backgroundImage: NetworkImage(crop.img!))
            : CircleAvatar(child: Icon(Icons.grass)),
        title: Text(
          crop.name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Get.theme.primaryColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expense:  ₹${crop.expense.toStringAsFixed(2)}'),
            Text('Sales:  ₹${crop.sales.toStringAsFixed(2)}'),
           
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    'Task:  ${crop.completedScheduleCount}/ ${crop.totalScheduleCount}',
                  ),
                ),
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
}
