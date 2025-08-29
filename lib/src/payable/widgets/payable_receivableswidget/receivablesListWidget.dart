import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/payables_receivables_model/payables_receivables_model.dart';
import '../../pages/customer/customer_sales_page.dart';
import '../../pages/customer_vendor/customer_vendor_page.dart';
import '../../pages/vendor/vendor_purchase_page.dart';

class ReceivablesList extends StatelessWidget {

  final List<ReceivableCustomer>? customerReceivables;
  final List<ReceivableVendor>? vendorReceivables;
  final List<BothCustomerVendor>? bothCustomerVendorReceivables;
  final int selectedTopToggle;

  const ReceivablesList({
    super.key,
    required this.selectedTopToggle,
    this.customerReceivables,
    this.vendorReceivables,
    this.bothCustomerVendorReceivables,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];

    switch (selectedTopToggle) {
      case 0:
        if (customerReceivables == null || customerReceivables!.isEmpty) {
          return const Center(child: Text('No receivables found.'));
        }
        items = customerReceivables!.map(_buildCustomerReceivableTile).toList();
        break;
      case 1:
        if (vendorReceivables == null || vendorReceivables!.isEmpty) {
          return const Center(child: Text('No receivables found.'));
        }
        items = vendorReceivables!.map(_buildVendorReceivableTile).toList();
        break;
      case 2:
      default:
        if (bothCustomerVendorReceivables == null ||
            bothCustomerVendorReceivables!.isEmpty) {
          return const Center(child: Text('No receivables found.'));
        }
        items =
            bothCustomerVendorReceivables!
                .map(_buildBothReceivableTile)
                .toList();
        break;
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items,
    );
  }

  Widget _buildCustomerReceivableTile(ReceivableCustomer item) {
    return InkWell(
      onTap: () {
        Get.to(
          () => CustomerSalesPage(
           
            customer_Id: item.id,
            customerName: item.customerName,
            amount: item.openingBalance,
            isPayable: false,
          ),
        );
      },
      child: _tile(
        item.customerName,
        'Shop: ${item.shopName}',
        item.openingBalance,
        item.isCredit,
      ),
    );
  }

  Widget _buildVendorReceivableTile(ReceivableVendor item) {
    return InkWell(
      onTap: () {
        Get.to(
          () => VendorPurchasePage(
           
            vendorId: item.id,
            isPayable: false,
          ),
        );
      },
      child: _tile(
        item.vendorName,
        'Business: ${item.businessName}',
        item.openingBalance,
        item.isCredit,
      ),
    );
  }

  /*  Widget _buildBothReceivableTile(BothCustomerVendor item) {
    final title = item.customerName ?? item.vendorName ?? 'Unknown';
    final subtitle = item.shopName ?? item.businessName ?? '';
    return InkWell(
      onTap: () {
        Get.to(
          () => CustomerVendorDetailsPage(
            id: 339,
            detailsType: DetailsType.receivables,
          ),
        );
      },
      child: _tile(title, subtitle, item.openingBalance, item.isCredit),
    );
  }*/
  Widget _buildBothReceivableTile(BothCustomerVendor item) {
    // Title
    String title = 'Unknown';
    if (item.customerName != null && item.customerName!.isNotEmpty) {
      title = "Customer Name: ${item.customerName}";
    } else if (item.vendorName != null && item.vendorName!.isNotEmpty) {
      title = "Vendor Name: ${item.vendorName}";
    }

    // Subtitle
    String subtitle = '';
    if (item.shopName != null && item.shopName!.isNotEmpty) {
      subtitle = "Shop Name: ${item.shopName}";
    } else if (item.businessName != null && item.businessName!.isNotEmpty) {
      subtitle = "Business Name: ${item.businessName}";
    }

    return InkWell(
      onTap: () {
        Get.to(
          () => CustomerVendorDetailsPage(
            id: 339,
            detailsType: DetailsType.receivables,
          ),
        );
      },
      child: _tile(title, subtitle, item.openingBalance, item.isCredit),
    );
  }

  Widget _tile(String title, String subtitle, double amount, bool isCredit) {
    return Container(
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
          '₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Icon(isCredit ? Icons.credit_card : Icons.money_off),
      ),
    );
  }
}
