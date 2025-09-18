import 'package:argiot/src/app/modules/expense/model/consumption_record.dart';
import 'package:argiot/src/app/modules/expense/view/widgets/month_day_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class ConsumptionList extends StatelessWidget {
  final List<ConsumptionItem> records;
  final int type;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final bool hasMore;

  const ConsumptionList({
    super.key,
    required this.records,
    required this.type,
    required this.scrollController,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(child: Text('no_consumption_records'.tr));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: records.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == records.length) {
          // Loading indicator at the end
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: isLoadingMore
                  ? const CircularProgressIndicator()
                  : Text('no_more_data'.tr),
            ),
          );
        }

        final record = records[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MonthDayFormat(date: record.dateOfConsumption),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (record.cropId != null)
                        Text(record.cropName??'', style: Get.textTheme.titleMedium),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                Text(
                  '${record.quantity} ',
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