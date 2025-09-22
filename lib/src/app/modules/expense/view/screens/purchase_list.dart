import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../model/purchase_record.dart';
import '../widgets/month_day_format.dart';

class PurchaseList extends StatelessWidget {
  final List<PurchaseItem> records;
  final int type;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final bool hasMore;

  const PurchaseList({
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
      return Center(child: Text('no_purchase_records'.tr));
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
                  : const SizedBox.shrink(),
            ),
          );
        }

        final record = records[index];
        return InkWell(
          onTap: () {
            Get.toNamed(
              Routes.inventoryPurchaseDetail,
              arguments: {"id": record.id, 'type': type},
            );
          },
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        Text(
                          record.vendor?.name ?? " ",
                          style: Get.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        if (record.quantity != null)
                          Text(
                            '${record.quantity!.round()} ${record.unitType}',
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '₹ ${record.purchaseAmount.toStringAsFixed(2)}',
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
