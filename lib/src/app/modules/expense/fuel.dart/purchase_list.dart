import 'package:argiot/src/app/modules/expense/fuel.dart/test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model.dart';

class PurchaseList extends StatelessWidget {
  final List<PurchaseRecord> records;

  const PurchaseList({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Center(child: Text('no_purchase_records'.tr));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return InkWell(
          onTap: (){
            Get.toNamed('/fuel_inventory',arguments: {"id":record.id});
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
          
                children: [
                  // Leading (Date)
                  _formatDate(record.date),
          
                  const SizedBox(width: 12),
          
                  // Title + Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.vendorName, style: Get.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('${record.quantity} ${record.quantityUnit}'),
                        // if (record.description.isNotEmpty)
                        //   Text(record.description),
                      ],
                    ),
                  ),
          
                  // Trailing (Amount)
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

  Widget _formatDate(DateTime date) {
    return Column(
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
  }

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
