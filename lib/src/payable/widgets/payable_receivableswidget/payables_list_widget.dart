/*import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/service/utils/enums.dart';
import '../../model/payables_receivables_model/payables_receivables_model.dart';
import '../../pages/customer/customer_sales_page.dart';
import '../../pages/customer_vendor/customer_vendor_page.dart';
import '../../pages/vendor/vendor_purchase_page.dart';

class PayablesList extends StatelessWidget {
  final List<PayableCustomer>? customerPayables;
  final List<PayableVendor>? vendorPayables;
  final List<BothCustomerVendor>? bothCustomerVendorPayables;
  final int selectedTopToggle;

  const PayablesList({
    super.key,
    required this.selectedTopToggle,
    this.customerPayables,
    this.vendorPayables,
    this.bothCustomerVendorPayables,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    switch (selectedTopToggle) {
      case 0:
        if (customerPayables == null || customerPayables!.isEmpty) {
          return Center(child: Text('no_payables_found'.tr));
        }
        items = customerPayables!.map(_buildCustomerPayableTile).toList();
        break;
      case 1:
        if (vendorPayables == null || vendorPayables!.isEmpty) {
          return Center(child: Text('no_payables_found'.tr));
        }
        items = vendorPayables!.map(_buildVendorPayableTile).toList();
        break;
      case 2:
      default:
        if (bothCustomerVendorPayables == null ||
            bothCustomerVendorPayables!.isEmpty) {
          return Center(child: Text('no_payables_found'.tr));
        }
        items = bothCustomerVendorPayables!.map(_buildBothPayableTile).toList();
        break;
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }

  Widget _buildCustomerPayableTile(PayableCustomer item) => InkWell(
    onTap: () {
      Get.to(
        () => CustomerSalesPage(
          customerId: item.id,
          customerName: item.customerName,
          amount: item.openingBalance,
          isPayable: true,
        ),
      );
    },
    child: _tile(
      item.customerName,
      '${'shop'.tr}: ${item.shopName}',
      item.openingBalance,
      item.isCredit,
    ),
  );

  Widget _buildVendorPayableTile(PayableVendor item) => InkWell(
    onTap: () {
      Get.to(() => VendorPurchasePage(vendorId: item.id, isPayable: true));
    },
    child: _tile(
      item.vendorName,
      '${'business'.tr}: ${item.businessName}',
      item.openingBalance,
      item.isCredit,
    ),
  );

  Widget _buildBothPayableTile(BothCustomerVendor item) {
    // Title with labels
    String title = 'unknown'.tr;
    if (item.customerName != null && item.customerName!.isNotEmpty) {
      title = "${'customer_name'.tr}: ${item.customerName}";
    } else if (item.vendorName != null && item.vendorName!.isNotEmpty) {
      title = "${'vendor_name'.tr}: ${item.vendorName}";
    }

    // Subtitle with labels
    String subtitle = '';
    if (item.shopName != null && item.shopName!.isNotEmpty) {
      subtitle = "${'shop'.tr}: ${item.shopName}";
    } else if (item.businessName != null && item.businessName!.isNotEmpty) {
      subtitle = "${'business'.tr}: ${item.businessName}";
    }

    return InkWell(
      onTap: () {
        Get.to(
          () => const CustomerVendorDetailsPage(
            detailsType: DetailsType.payables,
          ),
        );
      },
      child: _tile(title, subtitle, item.openingBalance, item.isCredit),
    );
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
          // leading: Icon(isCredit ? Icons.credit_card : Icons.money),
        ),
      );
}*/

import 'package:argiot/src/payable/controller/controllerpay_receive/pay_receivecontroller.dart';
import 'package:argiot/src/payable/pages/customer/customer_sales_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*class PayablesList extends StatelessWidget {
  final List<Customerlistmodel>? customerPayables;
  final List<Customerlistmodel>? vendorPayables;
  final int selectedTopToggle; // 0 = Customer, 1 = Vendor

  const PayablesList({
    super.key,
    required this.selectedTopToggle,
    this.customerPayables,
    this.vendorPayables,
  });

  @override
  Widget build(BuildContext context) {
    final items =
        (selectedTopToggle == 0 ? customerPayables : vendorPayables) ?? [];

    if (items.isEmpty) {
      return Center(child: Text('no_payables_found'.tr));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return InkWell(
          */ /*onTap: () {
            if (selectedTopToggle == 0) {
                Get.to(
                () => CustomerSalesPage(
                  customerId: item.id,
                  customerName: item.name,
                  amount: item.balance,
                  isPayable: true,
                ),
              );
            } else {
               Get.to(
                () => VendorPurchasePage(vendorId: item.id, isPayable: true),
              );
            }
          },*/ /*
          onTap: () {},
          child: _tile(
            selectedTopToggle == 0 ? item.name : item.name,
            '${selectedTopToggle == 0 ? 'shop'.tr : 'business'.tr}: ${item.businessName}',
            item.balance,
            item.isCredit,
          ),
        );
      },
    );
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
}*/
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
          return InkWell(
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
