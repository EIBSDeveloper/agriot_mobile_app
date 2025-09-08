/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/vendorcontroller/vendorcontroller.dart';
import '../../model/vendor/vendor_history_model.dart';
import '../../repository/vendor_repository/vendor_repository.dart';

class VendorHistoryPage extends StatelessWidget {
  final int vendorId;
  final int fuelId;
  final String type;
  final bool isPayable;

  VendorHistoryPage({
    super.key,
    required this.vendorId,
    required this.fuelId,
    required this.type,
    required this.isPayable,
  });

  final VendorPurchaseController controller = Get.put(
    VendorPurchaseController(repository: VendorPurchaseRepository()),
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadVendorPayablesHistory(
          vendorId: vendorId,
          type: type,
          fuelId: fuelId,
        );
      } else {
        controller.loadVendorReceivablesHistory(
          vendorId: vendorId,
          type: type,
          fuelId: fuelId,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isPayable ? 'Payable History' : 'Receivable History'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final historyList =
            isPayable
                ? controller.vendorPayablesHistory
                : controller.vendorReceivablesHistory;

        if (historyList.isEmpty) {
          return Center(
            child: Text(
              isPayable
                  ? 'No payables history found.'
                  : 'No receivables history found.',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            if (isPayable) {
              final item = historyList[index] as VendorPayableHistoryModel;
              return _buildHistoryCard(
                context,
                title: 'Date ${item.paidDate}',
                fields: {
                  'Payment Amount': '₹${item.paymentAmount.toStringAsFixed(2)}',
                  'Balance': '₹${item.balance.toStringAsFixed(2)}',
                  'Paid': '₹${item.paid.toStringAsFixed(2)}',
                  'To Pay': '₹${item.toPay.toStringAsFixed(2)}',
                  'Total Paid': '₹${item.totalPaid.toStringAsFixed(2)}',
                  'Paid Date': item.paidDate,
                  'Description': item.description ?? '-',
                },
                onEyeTap: () {
                  _showHistoryDetailsDialog(
                    context,
                    id: item.id,
                    fields: {
                      'Payment Amount':
                          '₹${item.paymentAmount.toStringAsFixed(2)}',
                      'Balance': '₹${item.balance.toStringAsFixed(2)}',
                      'Paid': '₹${item.paid.toStringAsFixed(2)}',
                      'To Pay': '₹${item.toPay.toStringAsFixed(2)}',
                      'Total Paid': '₹${item.totalPaid.toStringAsFixed(2)}',
                      'Paid Date': item.paidDate,
                      'Description': item.description ?? '-',
                    },
                  );
                },
              );
            } else {
              final item = historyList[index] as VendorReceivableHistoryModel;
              return _buildHistoryCard(
                context,
                title: 'Date ${item.receivedDate}',
                fields: {
                  'Payment Amount': '₹${item.paymentAmount.toStringAsFixed(2)}',
                  'Balance': '₹${item.balance.toStringAsFixed(2)}',
                  'Received': '₹${item.received.toStringAsFixed(2)}',
                  'To Receive': '₹${item.toReceive.toStringAsFixed(2)}',
                  'Total Received': '₹${item.totalReceived.toStringAsFixed(2)}',
                  'Received Date': item.receivedDate,
                  'Description': item.description ?? '-',
                },
                onEyeTap: () {
                  _showHistoryDetailsDialog(
                    context,
                    id: item.id,
                    fields: {
                      'Payment Amount':
                          '₹${item.paymentAmount.toStringAsFixed(2)}',
                      'Balance': '₹${item.balance.toStringAsFixed(2)}',
                      'Received': '₹${item.received.toStringAsFixed(2)}',
                      'To Receive': '₹${item.toReceive.toStringAsFixed(2)}',
                      'Total Received':
                          '₹${item.totalReceived.toStringAsFixed(2)}',
                      'Received Date': item.receivedDate,
                      'Description': item.description ?? '-',
                    },
                  );
                },
              );
            }
          },
        );
      }),
    );
  }

  /// History card with Eye icon
  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    required Map<String, String> fields,
    required VoidCallback onEyeTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // white background
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.black54),
                  onPressed: onEyeTap,
                ),
              ],
            ),
            const Divider(thickness: 1.2, height: 20, color: Colors.grey),
            ...fields.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Flexible(
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
            ),
          ],
        ),
      ),
    );
  }

  /// Show details dialog
  void _showHistoryDetailsDialog(
    BuildContext context, {
    required int id,
    required Map<String, String> fields,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.white, // white background
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    fields.entries
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
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/vendorcontroller/vendorcontroller.dart';
import '../../model/vendor/vendor_history_model.dart';
import '../../repository/vendor_repository/vendor_repository.dart';

class VendorHistoryPage extends StatelessWidget {
  final int vendorId;
  final int fuelId;
  final String type;
  final bool isPayable;

  VendorHistoryPage({
    super.key,
    required this.vendorId,
    required this.fuelId,
    required this.type,
    required this.isPayable,
  });

  final VendorPurchaseController controller = Get.put(
    VendorPurchaseController(repository: VendorPurchaseRepository()),
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadVendorPayablesHistory(
          vendorId: vendorId,
          type: type,
          fuelId: fuelId,
        );
      } else {
        controller.loadVendorReceivablesHistory(
          vendorId: vendorId,
          type: type,
          fuelId: fuelId,
        );
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

        final historyList =
            isPayable
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
        );
      }),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.black54),
                  onPressed: onEyeTap,
                ),
              ],
            ),
            const Divider(thickness: 1.2, height: 20, color: Colors.grey),
            ...fields.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Flexible(
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
            ),
          ],
        ),
      ),
    );

  void _showHistoryDetailsDialog(
    BuildContext context, {
    required int id,
    required Map<String, String> fields,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
                children:
                    fields.entries
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
  }
}
