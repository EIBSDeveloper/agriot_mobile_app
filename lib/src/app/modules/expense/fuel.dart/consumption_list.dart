import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model.dart';

class ConsumptionList extends StatelessWidget {
  final List<ConsumptionRecord> records;

  const ConsumptionList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(child: Text('no_consumption_records'.tr));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Leading (Date)
                _formatDate(record.dateOfConsumption),

                const SizedBox(width: 12),

                // Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (record.crop != null)
                        Text(record.crop!, style: Get.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      // Text('available: ${record.availableQuantity} units'),
                    ],
                  ),
                ),

                // Trailing (Quantity Utilized)
                Text(
                  '${record.quantityUtilized} ',
                  style: Get.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _formatDate(DateTime date) => Column(
      children: [
        Text(
          _getMonthName(date.month),
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          date.day.toString(),
          style: TextStyle(
            color: Get.theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
