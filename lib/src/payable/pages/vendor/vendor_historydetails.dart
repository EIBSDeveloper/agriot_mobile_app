/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/vendorcontroller/vendorcontroller.dart';
import '../../model/vendor/vendor_history_model.dart';
import '../../repository/vendor_repository/vendor_repository.dart';

class VendorHistoryPage extends StatelessWidget {
  final int userId;
  final int vendorId;
  final int fuelId;
  final String type;
  final bool isPayable;

  VendorHistoryPage({
    Key? key,
    required this.userId,
    required this.vendorId,
    required this.fuelId,
    required this.type,
    required this.isPayable,
  }) : super(key: key);

  final VendorPurchaseController controller = Get.put(
    VendorPurchaseController(repository: VendorPurchaseRepository()),
  );

  @override
  Widget build(BuildContext context) {
    // Load history after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadVendorPayablesHistory(
          userId: userId,
          vendorId: vendorId,
          type: type,
          fuelId: fuelId,
        );
      } else {
        controller.loadVendorReceivablesHistory(
          userId: userId,
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
                color: Colors.red.shade50,
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
                color: Colors.green.shade50,
              );
            }
          },
        );
      }),
    );
  }

  /// Premium history card
  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    required Map<String, String> fields,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1.2, height: 20),
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
                      ),
                    ),
                    Flexible(
                      child: Text(
                        e.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14),
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
}
*/

/*import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/vendorcontroller/vendorcontroller.dart';
import '../../model/vendor/vendor_history_model.dart';
import '../../repository/vendor_repository/vendor_repository.dart';

class VendorHistoryPage extends StatelessWidget {
  final int userId;
  final int vendorId;
  final int fuelId;
  final String type;
  final bool isPayable;

  VendorHistoryPage({
    Key? key,
    required this.userId,
    required this.vendorId,
    required this.fuelId,
    required this.type,
    required this.isPayable,
  }) : super(key: key);

  final VendorPurchaseController controller = Get.put(
    VendorPurchaseController(repository: VendorPurchaseRepository()),
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadVendorPayablesHistory(
          userId: userId,
          vendorId: vendorId,
          type: type,
          fuelId: fuelId,
        );
      } else {
        controller.loadVendorReceivablesHistory(
          userId: userId,
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
                color: Colors.red.shade50,
                onEyeTap: () {
                  _showHistoryDetailsDialog(
                    context,
                    id: item.id, // <-- pass ID
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
                    bgColor: Colors.red.shade50,
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
                color: Colors.green.shade50,
                onEyeTap: () {
                  _showHistoryDetailsDialog(
                    context,
                    id: item.id, // <-- pass ID
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
                    bgColor: Colors.green.shade50,
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
    required Color color,
    required VoidCallback onEyeTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: color,
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.grey),
                  onPressed: onEyeTap,
                ),
              ],
            ),
            const Divider(thickness: 1.2, height: 20),
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
                      ),
                    ),
                    Flexible(
                      child: Text(
                        e.value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14),
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
  /// Show details dialog
  void _showHistoryDetailsDialog(
    BuildContext context, {
    required int id,
    required Map<String, String> fields,
    required Color bgColor, // 👈 added
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: bgColor, // 👈 apply background color
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'History Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        bgColor == Colors.red.shade50
                            ? Colors.red
                            : Colors.green,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.close),
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
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14),
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
                width: 100, // full width button
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        bgColor == Colors.red.shade50
                            ? Colors.red
                            : Colors.green,
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
}*/

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
