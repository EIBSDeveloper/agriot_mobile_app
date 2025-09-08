
import 'package:flutter/material.dart';
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
            id: 339, // use actual ID
            detailsType: DetailsType.payables,
          ),
        );
      },
      child: _tile(title, subtitle, item.openingBalance, item.isCredit),
    );
  }

  Widget _tile(String title, String subtitle, double amount, bool isCredit) => Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
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
          ),
        ),
        leading: Icon(isCredit ? Icons.credit_card : Icons.money),
      ),
    );
}
