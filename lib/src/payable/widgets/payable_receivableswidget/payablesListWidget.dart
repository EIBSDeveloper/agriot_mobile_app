import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          return const Center(child: Text('No payables found.'));
        }
        items = customerPayables!.map(_buildCustomerPayableTile).toList();
        break;
      case 1:
        if (vendorPayables == null || vendorPayables!.isEmpty) {
          return const Center(child: Text('No payables found.'));
        }
        items = vendorPayables!.map(_buildVendorPayableTile).toList();
        break;
      case 2:
      default:
        if (bothCustomerVendorPayables == null ||
            bothCustomerVendorPayables!.isEmpty) {
          return const Center(child: Text('No payables found.'));
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

  Widget _buildCustomerPayableTile(PayableCustomer item) {
    return InkWell(
      onTap: () {
        Get.to(
          () => CustomerSalesPage(
          
            customer_Id: item.id,
            customerName: item.customerName,
            amount: item.openingBalance,
            isPayable: true,
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

  Widget _buildVendorPayableTile(PayableVendor item) {
    return InkWell(
      onTap: () {
        Get.to(
          () => VendorPurchasePage(
            
            vendorId: item.id,
            isPayable: true,
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

  /*  Widget _buildBothPayableTile(BothCustomerVendor item) {
    final title = item.customerName ?? item.vendorName ?? 'Unknown';
    final subtitle = item.shopName ?? item.businessName ?? '';
    return InkWell(
      onTap: () {
        Get.to(
          () => CustomerVendorDetailsPage(
            id: 339,
            detailsType: DetailsType.payables,
          ),
        );
      },
      child: _tile(title, subtitle, item.openingBalance, item.isCredit),
    );
  }*/
  Widget _buildBothPayableTile(BothCustomerVendor item) {
    // Title with labels
    String title = 'Unknown';
    if (item.customerName != null && item.customerName!.isNotEmpty) {
      title = "Customer Name: ${item.customerName}";
    } else if (item.vendorName != null && item.vendorName!.isNotEmpty) {
      title = "Vendor Name: ${item.vendorName}";
    }

    // Subtitle with labels
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
            id: 339, // use actual ID
            detailsType: DetailsType.payables,
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
