import 'package:argiot/src/payable/controller/controllerpay_receive/pay_receivecontroller.dart';
import 'package:argiot/src/payable/pages/customer/customer_sales_page.dart';
import 'package:argiot/src/payable/pages/vendor/vendor_purchase_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceivablesList extends StatelessWidget {
  final int selectedTopToggle; // 0 = Customer, 1 = Vendor
  final CustomerlistController controller = Get.find<CustomerlistController>();

  ReceivablesList({super.key, required this.selectedTopToggle}) {
    // Setup scroll listener for this tab
    controller.setupReceivablesPagination(selectedTopToggle);
  }

  @override
  Widget build(BuildContext context) {
    final items = selectedTopToggle == 0
        ? controller.customerReceivables
        : controller.vendorReceivables;

    if (items.isEmpty) return Center(child: Text('no_receivables_found'.tr));

    return Obx(() {
      final displayedItems = items.sublist(
        0,
        controller.receivablesCurrentMax.value.clamp(0, items.length),
      );

      return ListView.builder(
        controller: controller.receivablesScrollController,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayedItems.length + 1,
        itemBuilder: (_, index) {
          if (index == displayedItems.length) {
            if (controller.receivablesCurrentMax.value < items.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (controller.receivablesEndMessage.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(controller.receivablesEndMessage.value),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }

          final item = displayedItems[index];
          /*return InkWell(
            onTap: () {
              Get.to(
                () => CustomerSalesPage(
                  customerId: item.id,
                  customerName: item.name,
                  amount: item.balance,
                  isPayable: false,
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
                // Customer receivable
                Get.to(
                  () => CustomerSalesPage(
                    customerId: item.id,
                    customerName: item.name,
                    amount: item.balance,
                    isPayable: false,
                  ),
                );
              } else {
                // Vendor receivable
                Get.to(
                  () => VendorPurchasePage(vendorId: item.id, isPayable: false),
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
            '+ ₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Get.theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
}
