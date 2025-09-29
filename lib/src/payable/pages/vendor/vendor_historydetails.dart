import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/vendorcontroller/vendorcontroller.dart';
import '../../model/vendor/vendor_history_model.dart';
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
      appBar: AppBar(
        title: Text(isPayable ? 'payable_history'.tr : 'receivable_history'.tr),
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

        /* return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            if (isPayable) {
              final item = historyList[index] as VendorPayableHistoryModel;
              return _buildHistoryCard(
                context,
                title: '${'date'.tr} ${item.paidDate}',
                fields: {
                  'payment_amount'.tr:
                      '₹${item.paymentAmount.toStringAsFixed(2)}',
                  'balance'.tr: '₹${item.balance.toStringAsFixed(2)}',
                  'paid'.tr: '₹${item.paid.toStringAsFixed(2)}',
                  'to_pay'.tr: '₹${item.toPay.toStringAsFixed(2)}',
                  'total_paid'.tr: '₹${item.totalPaid.toStringAsFixed(2)}',
                  'paid_date'.tr: item.paidDate,
                  'description'.tr: item.description ?? '-',
                },
                onEyeTap: () {
                  _showHistoryDetailsDialog(
                    context,
                    id: item.id,
                    fields: {
                      'payment_amount'.tr:
                          '₹${item.paymentAmount.toStringAsFixed(2)}',
                      'balance'.tr: '₹${item.balance.toStringAsFixed(2)}',
                      'paid'.tr: '₹${item.paid.toStringAsFixed(2)}',
                      'to_pay'.tr: '₹${item.toPay.toStringAsFixed(2)}',
                      'total_paid'.tr: '₹${item.totalPaid.toStringAsFixed(2)}',
                      'paid_date'.tr: item.paidDate,
                      'description'.tr: item.description ?? '-',
                    },
                  );
                },
              );
            } else {
              final item = historyList[index] as VendorReceivableHistoryModel;
              return _buildHistoryCard(
                context,
                title: '${'date'.tr} ${item.receivedDate}',
                fields: {
                  'payment_amount'.tr:
                      '₹${item.paymentAmount.toStringAsFixed(2)}',
                  'balance'.tr: '₹${item.balance.toStringAsFixed(2)}',
                  'received'.tr: '₹${item.received.toStringAsFixed(2)}',
                  'to_receive'.tr: '₹${item.toReceive.toStringAsFixed(2)}',
                  'total_received'.tr:
                      '₹${item.totalReceived.toStringAsFixed(2)}',
                  'received_date'.tr: item.receivedDate,
                  'description'.tr: item.description ?? '-',
                },
                onEyeTap: () {
                  _showHistoryDetailsDialog(
                    context,
                    id: item.id,
                    fields: {
                      'payment_amount'.tr:
                          '₹${item.paymentAmount.toStringAsFixed(2)}',
                      'balance'.tr: '₹${item.balance.toStringAsFixed(2)}',
                      'received'.tr: '₹${item.received.toStringAsFixed(2)}',
                      'to_receive'.tr: '₹${item.toReceive.toStringAsFixed(2)}',
                      'total_received'.tr:
                          '₹${item.totalReceived.toStringAsFixed(2)}',
                      'received_date'.tr: item.receivedDate,
                      'description'.tr: item.description ?? '-',
                    },
                  );
                },
              );
            }
          },
        );*/
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            if (isPayable) {
              final item = historyList[index] as VendorHistoryModel;
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
                  'description'.tr: item.description ?? '-',
                },
                onEyeTap: () {
                  _showHistoryDetailsDialog(
                    context,
                    id: item.id,
                    fields: {
                      'payment_amount'.tr:
                          '₹${item.paymentAmount.toStringAsFixed(2)}',
                      'balance'.tr: '₹${item.balance.toStringAsFixed(2)}',
                      'paid'.tr: '₹${item.paid.toStringAsFixed(2)}',
                      'to_pay'.tr: '₹${item.toPay.toStringAsFixed(2)}',
                      'total_paid'.tr: '₹${item.totalPaid.toStringAsFixed(2)}',
                      'paid_date'.tr: item.paidDate,
                      'description'.tr: item.description ?? '-',
                    },
                    isPayable: true,
                  );
                },
              );
            } else {
              final item = historyList[index] as VendorHistoryModel;
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
                  'description'.tr: item.description ?? '-',
                },
                onEyeTap: () {
                  /*_showHistoryDetailsDialog(
                    context,
                    id: item.id,
                    fields: {
                      'payment_amount'.tr:
                          '₹${item.paymentAmount.toStringAsFixed(2)}',
                      'balance'.tr: '₹${item.balance.toStringAsFixed(2)}',
                      'received'.tr: '₹${item.received.toStringAsFixed(2)}',
                      'to_receive'.tr: '₹${item.toReceive.toStringAsFixed(2)}',
                      'total_received'.tr:
                          '₹${item.totalReceived.toStringAsFixed(2)}',
                      'received_date'.tr: item.receivedDate,
                      'description'.tr: item.description ?? '-',
                    },
                    isPayable: false,
                  );*/
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
    required VoidCallback onEyeTap,
  }) => Card(
    elevation: 4,
    shadowColor: Colors.grey.shade300,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
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
              IconButton(
                icon: const Icon(Icons.remove_red_eye, color: Colors.black54),
                onPressed: onEyeTap,
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

  /*  void _showHistoryDetailsDialog(
    BuildContext context, {
    required int id,
    required Map<String, String> fields,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'history_details'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            InkWell(
              onTap: () => Get.back(),
              child: const Icon(Icons.close, color: Colors.black),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fields.entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${e.key}: ",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('close'.tr),
            ),
          ),
        ],
      ),
    );
  }*/
  void _showHistoryDetailsDialog(
    BuildContext context, {
    required int id,
    required Map<String, String> fields,
    required bool isPayable,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        "History Details",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              const Divider(thickness: 1.2, height: 20, color: Colors.grey),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: fields.entries.map((e) {
                      final isBalanceField = e.key.toLowerCase().contains(
                        'balance',
                      );
                      final textColor = isBalanceField
                          ? (isPayable
                                ? Colors.red
                                : Get.theme.colorScheme.primary)
                          : Colors.black87;
                      final fontSize = isBalanceField ? 18.0 : 14.0;
                      final fontWeight = isBalanceField
                          ? FontWeight.bold
                          : FontWeight.normal;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${e.key}: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize,
                                color: textColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                e.value,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: fontWeight,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Close button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Close'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
