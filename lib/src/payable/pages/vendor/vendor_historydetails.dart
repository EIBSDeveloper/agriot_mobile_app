import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/vendorcontroller/vendorcontroller.dart';
import '../../repository/vendor_repository/vendor_repository.dart';

class VendorHistoryPage extends StatelessWidget {
  final int expenseId;
  final bool isPayable; // Add this

  VendorHistoryPage({
    super.key,
    required this.expenseId,
    required this.isPayable,
  });

  final VendorPurchaseController controller = Get.put(
    VendorPurchaseController(repository: VendorPurchaseRepository()),
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadVendorPayablesHistory(expenseId);
      } else {
        controller.loadVendorReceivablesHistory(expenseId);
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: (isPayable ? 'payable_history'.tr : 'receivable_history'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final historyList = isPayable
            ? controller.vendorPayablesHistory
            : controller.vendorReceivablesHistory;

        if (historyList.isEmpty) {
          return Center(
            child: Text(
              isPayable
                  ? 'no_payables_history'.tr
                  : 'no_receivables_history'.tr,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            if (isPayable) {
              final item = historyList[index];
              return _buildHistoryCard(
                context,
                isPayable: true,
                title: '${'date'.tr} ${item.paidDate}',
                fields: {
                  'payment_amount'.tr:
                      '₹${item.paymentAmount.toStringAsFixed(2)}',
                  'balance'.tr: '₹${item.balance.toStringAsFixed(2)}',
                  'paid'.tr: '₹${item.paid.toStringAsFixed(2)}',
                  'to_pay'.tr: '₹${item.toPay.toStringAsFixed(2)}',
                  'total_paid'.tr: '₹${item.totalPaid.toStringAsFixed(2)}',
                  'paid_date'.tr: item.paidDate,
                  'description'.tr: item.description,
                },
              );
            } else {
              final item = historyList[index];
              return _buildHistoryCard(
                context,
                isPayable: false,
                title: '${'date'.tr} ${item.paidDate}',
                fields: {
                  'payment_amount'.tr:
                      '₹${item.paymentAmount.toStringAsFixed(2)}',
                  'balance'.tr: '₹${item.balance.toStringAsFixed(2)}',
                  'received'.tr: '₹${item.paid.toStringAsFixed(2)}',
                  'to_receive'.tr: '₹${item.toPay.toStringAsFixed(2)}',
                  'total_received'.tr: '₹${item.totalPaid.toStringAsFixed(2)}',
                  'received_date'.tr: item.paidDate,
                  'description'.tr: item.description,
                },
              );
            }
          },
        );
      }),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required bool isPayable,
    required String title,
    required Map<String, String> fields,
  }) => Card(
    elevation: 1,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title, // pass only the date here, e.g. `item.paidDate`
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(thickness: 1.2, height: 20, color: Colors.grey),
          ...fields.entries.map((e) {
            // Highlight balance field
            final isBalanceField = e.key.toLowerCase().contains('balance');
            final balanceColor = isBalanceField
                ? (isPayable ? Colors.red : Get.theme.colorScheme.primary)
                : Colors.black;
            final fontSize = isBalanceField
                ? 20.0
                : 14.0; // 👈 Bigger for balance

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.key,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      color: isBalanceField ? balanceColor : Colors.black87,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      e.value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: isBalanceField ? balanceColor : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ),
  );
}
