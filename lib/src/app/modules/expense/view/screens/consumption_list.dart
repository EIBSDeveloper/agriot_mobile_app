import 'package:argiot/src/app/modules/expense/model/consumption_record.dart';
import 'package:argiot/src/app/modules/expense/view/widgets/month_day_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ConsumptionList extends StatelessWidget {
  final List<ConsumptionRecord> records;
  final int type;
  const ConsumptionList({super.key, required this.records, required this.type});

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
                MonthDayFormat(date: record.dateOfConsumption),

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
}
