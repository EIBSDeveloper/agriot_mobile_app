import 'package:argiot/src/payable/controller/controllerpay_receive/pay_receivecontroller.dart';
import 'package:argiot/src/payable/pages/customer/customer_sales_page.dart';
import 'package:argiot/src/payable/pages/vendor/vendor_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayablesList extends StatelessWidget {
  final int selectedTopToggle; // 0 = Customer, 1 = Vendor
  final CustomerlistController controller = Get.find<CustomerlistController>();

  PayablesList({super.key, required this.selectedTopToggle}) {
    // Setup scroll listener for this tab
    controller.setupPayablesPagination(selectedTopToggle);
  }

  @override
  Widget build(BuildContext context) {
    final items = selectedTopToggle == 0
        ? controller.customerPayables
        : controller.vendorPayables;

    if (items.isEmpty) return Center(child: Text('no_payables_found'.tr));

    return Obx(() {
      final displayedItems = items.sublist(
        0,
        controller.payablesCurrentMax.value.clamp(0, items.length),
      );

      return ListView.builder(
        controller: controller.payablesScrollController,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayedItems.length + 1, // +1 for loading indicator
        itemBuilder: (_, index) {
          if (index == displayedItems.length) {
            // Show loader if more items available
            if (controller.payablesCurrentMax.value < items.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (controller.payablesEndMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(controller.payablesEndMessage.value)),
              );
            } else {
              return const SizedBox.shrink();
            }
          }

          final item = displayedItems[index];
          /* return InkWell(
            onTap: () {
              Get.to(
                () => CustomerSalesPage(
                  customerId: item.id,
                  customerName: item.name,
                  amount: item.balance,
                  isPayable: true,
                ),
              );
            },
            child: _tile(
              item.name,
              '${selectedTopToggle == 0 ? 'shop'.tr : 'business'.tr}: ${item.businessName}',
              item.balance,
              item.isCredit,
            ),
          );*/
          return InkWell(
            onTap: () {
              if (selectedTopToggle == 0) {
                // Customer payable
                Get.to(
                  () => CustomerSalesPage(
                    customerId: item.id,
                    customerName: item.name,
                    amount: item.balance,
                    isPayable: true,
                  ),
                );
              } else {
                // Vendor payable
                Get.to(
                  () => VendorPurchasePage(vendorId: item.id, isPayable: true),
                );
              }
            },
            child: _tile(
              item.name,
              '${selectedTopToggle == 0 ? 'shop'.tr : 'business'.tr}: ${item.businessName}',
              item.balance,
              item.isCredit,
            ),
          );
        },
      );
    });
  }

  Widget _tile(String title, String subtitle, double amount, bool isCredit) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(150),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Text(
            '- ₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
}
