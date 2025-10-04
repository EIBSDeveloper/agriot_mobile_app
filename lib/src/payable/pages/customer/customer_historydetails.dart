import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/widgets/loading.dart';
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

  final controller = Get.isRegistered<CustomerSalesController>()
      ? Get.find<CustomerSalesController>()
      : Get.put(CustomerSalesController(repository: CustomerSalesRepository()));

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
      /*appBar: AppBar(
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
      ),*/
      appBar: AppBar(
        title: Text(
          isPayable ? 'payables history'.tr : 'receivables history'.tr,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loading();
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final history = isPayable
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
          itemBuilder: (context, index) => AnimatedContainer(
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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: isPayable
                  ? _buildPayableItem(history[index] as PayableHistorymodel)
                  : _buildReceivableItem(
                      history[index] as ReceivableHistorymodel,
                    ),
            ),
          ),
        );
      }),
    );
  }

  // Update _buildPayableItem
  Widget _buildPayableItem(PayableHistorymodel item) => Column(
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
            onPressed: () => _showHistoryDetailDialog(
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

      // Balance in red, big font
      _buildAmountRow(
        'balance'.tr,
        item.balance,
        textColor: Colors.red,
        fontSize: 18,
      ),

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

  // Update _buildReceivableItem
  Widget _buildReceivableItem(ReceivableHistorymodel item) => Column(
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
            onPressed: () => _showHistoryDetailDialog(
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

      // Balance in green, big font
      _buildAmountRow(
        'balance'.tr,
        item.balance,
        textColor: Get.theme.colorScheme.primary,
        fontSize: 18,
      ),

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

  Future<void> _showHistoryDetailDialog({
    required BuildContext context,
    required int customerId,
    required int saleId,
    required int outstandingId,
    required bool isPayable,
  }) async {
    final controller = Get.isRegistered<CustomerSalesController>()
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
          child: detail == null
              ? Text(
                  'no_detail_found'.tr,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPayable
                                    ? detail.paidDate
                                    : detail.receivedDate,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Balance (Red for Payables, Green for Receivables)
                      _buildAmountRow(
                        'balance'.tr,
                        detail.balance,
                        textColor: isPayable
                            ? Colors.red
                            : Get.theme.colorScheme.primary,
                        fontSize: 18,
                      ),

                      // Common fields
                      if (isPayable) ...[
                        _buildAmountRow('paid'.tr, detail.paid),
                        _buildAmountRow(
                          'payment_amount'.tr,
                          detail.paymentAmount,
                        ),
                        _buildAmountRow('to_pay'.tr, detail.toPay),
                        _buildAmountRow('total_paid'.tr, detail.totalPaid),
                      ] else ...[
                        _buildAmountRow('received'.tr, detail.received),
                        _buildAmountRow(
                          'payment_amount'.tr,
                          detail.paymentAmount,
                        ),
                        _buildAmountRow('to_receive'.tr, detail.toReceive),
                        _buildAmountRow(
                          'total_received'.tr,
                          detail.totalReceived,
                        ),
                      ],

                      if ((detail.description ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "📝 ${detail.description}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),

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
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildAmountRow(
    String label,
    double value, {
    Color textColor = Colors.black,
    double fontSize = 14,
  }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$label:",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
              ),
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
}
