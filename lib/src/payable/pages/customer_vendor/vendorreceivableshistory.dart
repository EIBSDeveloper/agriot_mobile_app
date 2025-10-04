/*

import 'package:argiot/src/payable/repository/vendor_repository/vendor_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/vendorcontroller/vendorcontroller.dart';
import '../../model/vendor/vendor_history_model.dart';

class VendorHistoryPage extends StatelessWidget {
  final int vendorId;
  final int purchaseId;
  final String type;
  final bool isPayable; // 🔑 true = Payable, false = Receivable

  VendorHistoryPage({
    super.key,
    required this.vendorId,
    required this.purchaseId,
    required this.type,
    required this.isPayable,
  });

  final controller = Get.put(
    VendorPurchaseController(repository: VendorPurchaseRepository()),
  );

  @override
  Widget build(BuildContext context) {
    // 🔑 Trigger API on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadVendorPayablesHistory(
          vendorId: vendorId,
          type: type,
          fuelId: purchaseId,
        );
      } else {
        controller.loadVendorReceivablesHistory(
          vendorId: vendorId,
          type: type,
          fuelId: purchaseId,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isPayable ? "Vendor Payables History" : "Vendor Receivables History",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loading();
        }

        if (isPayable && controller.vendorPayablesHistory.isEmpty) {
          return const Center(
            child: Text(
              "No payables history found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        if (!isPayable && controller.vendorReceivablesHistory.isEmpty) {
          return const Center(
            child: Text(
              "No receivables history found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final historyList =
            isPayable
                ? controller.vendorPayablesHistory
                : controller.vendorReceivablesHistory;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isPayable
                              ? (item as VendorPayableHistoryModel).paidDate
                              : (item as VendorReceivableHistoryModel)
                                  .receivedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          onPressed: () => _showDetailDialog(item, context),
                        ),
                      ],
                    ),
                    if (isPayable) ...[
                      _buildRow(
                        "Balance",
                        (item as VendorPayableHistoryModel).balance,
                      ),
                      _buildRow("Paid", item.paid),
                      _buildRow("Payment", item.paymentAmount),
                      _buildRow("To Pay", item.toPay),
                      _buildRow("Total Paid", item.totalPaid),
                    ] else ...[
                      _buildRow(
                        "Balance",
                        (item as VendorReceivableHistoryModel).balance,
                      ),
                      _buildRow("Received", item.received),
                      _buildRow("Payment", item.paymentAmount),
                      _buildRow("To Receive", item.toReceive),
                      _buildRow("Total Received", item.totalReceived),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDetailDialog(dynamic item, BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPayable ? "Payable Detail" : "Receivable Detail",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRow(
                  "Date",
                  isPayable ? (item.paidDate ?? '') : (item.receivedDate ?? ''),
                ),
                _buildRow("Balance", item.balance),
                _buildRow(
                  isPayable ? "Paid" : "Received",
                  isPayable ? item.paid : item.received,
                ),
                _buildRow("Payment", item.paymentAmount),
                _buildRow(
                  isPayable ? "To Pay" : "To Receive",
                  isPayable ? item.toPay : item.toReceive,
                ),
                _buildRow(
                  isPayable ? "Total Paid" : "Total Received",
                  isPayable ? item.totalPaid : item.totalReceived,
                ),
                if ((item.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text("📝 ${item.description}"),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, dynamic value) {
    String text =
        value is double ? "₹${value.toStringAsFixed(2)}" : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text("$label:")),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
*/
