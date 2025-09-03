/*

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/customercontroller/customer_salaes_controller.dart';
import '../../model/customer_history/customer_sales_history.dart';
import '../../repository/customer_repository/customer_sales_repository.dart';

class HistoryPage extends StatelessWidget {

  final int customerId;
  final int saleId;
  final bool isPayable;

  HistoryPage({
    super.key,
    required this.customerId,
    required this.saleId,
    required this.isPayable,
  });

  final controller =
      Get.isRegistered<CustomerSalesController>()
          ? Get.find<CustomerSalesController>()
          : Get.put(
            CustomerSalesController(repository: CustomerSalesRepository()),
          );

  @override
  Widget build(BuildContext context) {
    // Load history after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadPayablesHistory(
         
          customerId: customerId,
          saleId: saleId,
        );
      } else {
        controller.loadReceivablesHistory(
         
          customerId: customerId,
          saleId: saleId,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.white,
        title: Text(
          isPayable ? "Payables History" : "Receivables History",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final history =
            isPayable
                ? controller.payablesHistory
                : controller.receivablesHistory;

        if (history.isEmpty) {
          return const Center(
            child: Text(
              "No history found",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: history.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white, // white background
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child:
                    isPayable
                        ? _buildPayableItem(
                          history[index] as PayableHistorymodel,
                        )
                        : _buildReceivableItem(
                          history[index] as ReceivableHistorymodel,
                        ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPayableItem(PayableHistorymodel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  item.paidDate,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.remove_red_eye, color: Colors.black),
              onPressed:
                  () => _showHistoryDetailDialog(
                    context: Get.context!,
                    customerId: customerId,
                    saleId: saleId,
                    outstandingId: item.id,
                    isPayable: true,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAmountRow("Balance", item.balance),
        _buildAmountRow("Paid", item.paid),
        _buildAmountRow("Payment Amount", item.paymentAmount),
        _buildAmountRow("To Pay", item.toPay),
        _buildAmountRow("Total Paid", item.totalPaid),
        if ((item.description ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "📝 ${item.description}",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildReceivableItem(ReceivableHistorymodel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  item.receivedDate,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.remove_red_eye, color: Colors.black),
              onPressed:
                  () => _showHistoryDetailDialog(
                    context: Get.context!,
                    customerId: customerId,
                    saleId: saleId,
                    outstandingId: item.id,
                    isPayable: false,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAmountRow("Balance", item.balance),
        _buildAmountRow("Received", item.received),
        _buildAmountRow("Payment Amount", item.paymentAmount),
        _buildAmountRow("To Receive", item.toReceive),
        _buildAmountRow("Total Received", item.totalReceived),
        if ((item.description ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "📝 ${item.description}",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Future<void> _showHistoryDetailDialog({
    required BuildContext context,
    required int customerId,
    required int saleId,
    required int outstandingId,
    required bool isPayable,
  }) async {
    final controller =
        Get.isRegistered<CustomerSalesController>()
            ? Get.find<CustomerSalesController>()
            : Get.put(
              CustomerSalesController(repository: CustomerSalesRepository()),
            );

    dynamic detail;
    String? error;

    try {
      if (isPayable) {
        await controller.loadPayableDetail(
          customerId: customerId,
          saleId: saleId,
          outstandingId: outstandingId,
        );
        detail = controller.selectedPayable.value;
      } else {
        await controller.loadReceivableDetail(
         
          customerId: customerId,
          saleId: saleId,
          outstandingId: outstandingId,
        );
        detail = controller.selectedReceivable.value;
      }
    } catch (e) {
      error = e.toString();
    }

    if (error != null) {
      Get.snackbar('Error', error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (Get.isDialogOpen == true) Get.back();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // white background
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child:
              detail == null
                  ? const Text(
                    "No detail found",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPayable ? Icons.money_off : Icons.attach_money,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPayable ? "Payable Detail" : "Receivable Detail",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildHistoryRow(
                        "Date",
                        isPayable ? detail.paidDate : detail.receivedDate,
                        textColor: Colors.black,
                      ),
                      _buildHistoryRow(
                        "Balance",
                        detail.balance,
                        textColor: Colors.black,
                      ),
                      _buildHistoryRow(
                        isPayable ? "Paid" : "Received",
                        isPayable ? detail.paid : detail.received,
                        textColor: Colors.black,
                      ),
                      _buildHistoryRow(
                        "Payment Amount",
                        detail.paymentAmount,
                        textColor: Colors.black,
                      ),
                      _buildHistoryRow(
                        isPayable ? "To Pay" : "To Receive",
                        isPayable ? detail.toPay : detail.toReceive,
                        textColor: Colors.black,
                      ),
                      _buildHistoryRow(
                        isPayable ? "Total Paid" : "Total Received",
                        isPayable ? detail.totalPaid : detail.totalReceived,
                        textColor: Colors.black,
                      ),
                      if ((detail.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "Description: ${detail.description}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text("Close"),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildHistoryRow(
    String label,
    dynamic value, {
    Color textColor = Colors.black,
  }) {
    String displayValue =
        value is double ? "₹${value.toStringAsFixed(2)}" : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            displayValue,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
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

import '../../controller/customercontroller/customer_salaes_controller.dart';
import '../../model/customer_history/customer_sales_history.dart';
import '../../repository/customer_repository/customer_sales_repository.dart';

class HistoryPage extends StatelessWidget {
  final int customerId;
  final int saleId;
  final bool isPayable;

  HistoryPage({
    super.key,
    required this.customerId,
    required this.saleId,
    required this.isPayable,
  });

  final controller =
      Get.isRegistered<CustomerSalesController>()
          ? Get.find<CustomerSalesController>()
          : Get.put(
            CustomerSalesController(repository: CustomerSalesRepository()),
          );

  @override
  Widget build(BuildContext context) {
    // Load history after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadPayablesHistory(customerId: customerId, saleId: saleId);
      } else {
        controller.loadReceivablesHistory(
          customerId: customerId,
          saleId: saleId,
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isPayable ? 'payables_history'.tr : 'receivables_history'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final history =
            isPayable
                ? controller.payablesHistory
                : controller.receivablesHistory;

        if (history.isEmpty) {
          return Center(
            child: Text(
              'no_history_found'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: history.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child:
                    isPayable
                        ? _buildPayableItem(
                          history[index] as PayableHistorymodel,
                        )
                        : _buildReceivableItem(
                          history[index] as ReceivableHistorymodel,
                        ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPayableItem(PayableHistorymodel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  item.paidDate,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.remove_red_eye, color: Colors.black),
              onPressed:
                  () => _showHistoryDetailDialog(
                    context: Get.context!,
                    customerId: customerId,
                    saleId: saleId,
                    outstandingId: item.id,
                    isPayable: true,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAmountRow('balance'.tr, item.balance),
        _buildAmountRow('paid'.tr, item.paid),
        _buildAmountRow('payment_amount'.tr, item.paymentAmount),
        _buildAmountRow('to_pay'.tr, item.toPay),
        _buildAmountRow('total_paid'.tr, item.totalPaid),
        if ((item.description ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "📝 ${item.description}",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildReceivableItem(ReceivableHistorymodel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  item.receivedDate,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.remove_red_eye, color: Colors.black),
              onPressed:
                  () => _showHistoryDetailDialog(
                    context: Get.context!,
                    customerId: customerId,
                    saleId: saleId,
                    outstandingId: item.id,
                    isPayable: false,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAmountRow('balance'.tr, item.balance),
        _buildAmountRow('received'.tr, item.received),
        _buildAmountRow('payment_amount'.tr, item.paymentAmount),
        _buildAmountRow('to_receive'.tr, item.toReceive),
        _buildAmountRow('total_received'.tr, item.totalReceived),
        if ((item.description ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "📝 ${item.description}",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Future<void> _showHistoryDetailDialog({
    required BuildContext context,
    required int customerId,
    required int saleId,
    required int outstandingId,
    required bool isPayable,
  }) async {
    final controller =
        Get.isRegistered<CustomerSalesController>()
            ? Get.find<CustomerSalesController>()
            : Get.put(
              CustomerSalesController(repository: CustomerSalesRepository()),
            );

    dynamic detail;
    String? error;

    try {
      if (isPayable) {
        await controller.loadPayableDetail(
          customerId: customerId,
          saleId: saleId,
          outstandingId: outstandingId,
        );
        detail = controller.selectedPayable.value;
      } else {
        await controller.loadReceivableDetail(
          customerId: customerId,
          saleId: saleId,
          outstandingId: outstandingId,
        );
        detail = controller.selectedReceivable.value;
      }
    } catch (e) {
      error = e.toString();
    }

    if (error != null) {
      Get.snackbar('error'.tr, error, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (Get.isDialogOpen == true) Get.back();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
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
          padding: const EdgeInsets.all(20),
          child:
              detail == null
                  ? Text(
                    'no_detail_found'.tr,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPayable ? Icons.money_off : Icons.attach_money,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPayable
                                ? 'payable_detail'.tr
                                : 'receivable_detail'.tr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildHistoryRow(
                        'date'.tr,
                        isPayable ? detail.paidDate : detail.receivedDate,
                      ),
                      _buildHistoryRow('balance'.tr, detail.balance),
                      _buildHistoryRow(
                        isPayable ? 'paid'.tr : 'received'.tr,
                        isPayable ? detail.paid : detail.received,
                      ),
                      _buildHistoryRow(
                        'payment_amount'.tr,
                        detail.paymentAmount,
                      ),
                      _buildHistoryRow(
                        isPayable ? 'to_pay'.tr : 'to_receive'.tr,
                        isPayable ? detail.toPay : detail.toReceive,
                      ),
                      _buildHistoryRow(
                        isPayable ? 'total_paid'.tr : 'total_received'.tr,
                        isPayable ? detail.totalPaid : detail.totalReceived,
                      ),
                      if ((detail.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          "${'description'.tr}: ${detail.description}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Get.back(),
                          child: Text('close'.tr),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildHistoryRow(
    String label,
    dynamic value, {
    Color textColor = Colors.black,
  }) {
    String displayValue =
        value is double ? "₹${value.toStringAsFixed(2)}" : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            displayValue,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
