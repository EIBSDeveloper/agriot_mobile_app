
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/service/utils/utils.dart';
import '../../controller/customer_vendor_controller/customer_vendor_controller.dart';
import '../../model/customer_history/customer_sales_history.dart';
import '../../repository/customer_vendor_repository/customer_vendor_repository.dart';

class HistoryDetailsPage extends StatelessWidget {

  final int customerId;
  final int saleId;
  final bool isPayable;

  HistoryDetailsPage({
    super.key,
    required this.customerId,
    required this.saleId,
    required this.isPayable,
  });

  final controller = Get.put(
    CustomerVendorController(repository: CustomerVendorRepository()),
  );

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadpayableHistory( customerId, saleId);
      } else {
        controller.loadReceivableHistory( customerId, saleId);
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isPayable
              ? "customer_payables_history".tr
              : "customer_receivables_history".tr,
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

        final list =
            isPayable ? controller.historypayableList : controller.historyList;

        if (list.isEmpty) {
          return Center(
            child: Text(
              "no_history_found".tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
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
                          item as PayableHistorymodel,
                          context,
                        )
                        : _buildReceivableItem(
                          item as ReceivableHistorymodel,
                          context,
                        ),
              ),
            );
          },
        );
      }),
    );
  }

  // Receivable UI
  Widget _buildReceivableItem(
    ReceivableHistorymodel item,
    BuildContext context,
  ) => Column(
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
                    context: context,
                    customerId: customerId,
                    saleId: saleId,
                    outstandingId: item.id,
                    isPayable: false,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAmountRow("balance".tr, item.balance),
        _buildAmountRow("received".tr, item.received),
        _buildAmountRow("payment_amount".tr, item.paymentAmount),
        _buildAmountRow("to_receive".tr, item.toReceive),
        _buildAmountRow("total_received".tr, item.totalReceived),
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

  // Payable UI
  Widget _buildPayableItem(PayableHistorymodel item, BuildContext context) {
    String formatDate(String rawDate) {
      try {
        final date = DateTime.parse(rawDate);
        return DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        return rawDate;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                 Icon(Icons.calendar_today,color: Get.theme.colorScheme.primary,),
                const SizedBox(width: 8),
                Text(
                  formatDate(
                    item.paidDate.isNotEmpty ? item.paidDate : item.createdAt,
                  ),
                  style: const TextStyle(
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
                    context: context,
                  
                    customerId: customerId,
                    saleId: saleId,
                    outstandingId: item.id,
                    isPayable: true,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildAmountRow("balance".tr, item.balance),
        _buildAmountRow("paid".tr, item.paid),
        _buildAmountRow("payment_amount".tr, item.paymentAmount),
        _buildAmountRow("to_pay".tr, item.toPay),
        _buildAmountRow("total_paid".tr, item.totalPaid),
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
    if (isPayable) {
      await controller.loadSinglepayableHistory(
 
        customerId,
        saleId,
        outstandingId,
      );
    } else {
      await controller.loadSingleReceivableHistory(
 
        customerId,
        saleId,
        outstandingId,
      );
    }

    final detail =
        isPayable
            ? controller.selectedpayableHistory.value
            : controller.selectedHistory.value;

    if (detail == null) {
     showError(
        "no_detail_found".tr,
      
      );
      return;
    }

    Widget buildHistoryRow(String label, dynamic value) {
      String displayValue =
          value == null
              ? "-"
              : (value is double
                  ? "₹${value.toStringAsFixed(2)}"
                  : value.toString());
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text("$label:")),
            Text(
              displayValue,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPayable ? "payable_detail".tr : "receivable_detail".tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              if (isPayable) ...[
                buildHistoryRow(
                  "date".tr,
                  (detail as PayableHistorymodel).paidDate,
                ),
                buildHistoryRow("balance".tr, detail.balance),
                buildHistoryRow("paid".tr, detail.paid),
                buildHistoryRow("payment_amount".tr, detail.paymentAmount),
                buildHistoryRow("to_pay".tr, detail.toPay),
                buildHistoryRow("total_paid".tr, detail.totalPaid),
                if ((detail.description ?? '').isNotEmpty)
                  Text("${"description".tr}: ${detail.description}"),
              ] else ...[
                buildHistoryRow(
                  "date".tr,
                  (detail as ReceivableHistorymodel).receivedDate,
                ),
                buildHistoryRow("balance".tr, detail.balance),
                buildHistoryRow("received".tr, detail.received),
                buildHistoryRow("payment_amount".tr, detail.paymentAmount),
                buildHistoryRow("to_receive".tr, detail.toReceive),
                buildHistoryRow("total_received".tr, detail.totalReceived),
                if ((detail.description ?? '').isNotEmpty)
                  Text("${"description".tr}: ${detail.description}"),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text("close".tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text("$label:")),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
}
