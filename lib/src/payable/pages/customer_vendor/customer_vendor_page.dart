import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/customer_vendor_controller/customer_vendor_controller.dart';
import '../../repository/customer_vendor_repository/customer_vendor_repository.dart';

enum DetailsType { payables, receivables }

class CustomerVendorDetailsPage extends StatelessWidget {
  final int id;
  final DetailsType? detailsType;

  final controller = Get.put(
    CustomerVendorController(repository: CustomerVendorRepository()),
  );

  CustomerVendorDetailsPage({
    super.key,
    required this.id,
    required this.detailsType,
  }) {
    controller.loadPayables(id);
    controller.loadReceivables(id);
  }

  Widget buildFuelReceivablesList(List fuelReceivables) {
    if (fuelReceivables.isEmpty) return Text("No Fuel Receivables");

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: fuelReceivables.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final fuel = fuelReceivables[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Purchase Date: ${fuel.purchaseDate}"),
            Text("Inventory Type: ${fuel.inventoryType}"),
            Text("Inventory Item: ${fuel.inventoryItem}"),
            Text("Total Purchase Amount: ₹${fuel.totalPurchaseAmount}"),
            Text("Amount Paid: ₹${fuel.amountPaid}"),
            Text("Received Amount: ₹${fuel.receivedAmount}"),
            Text("To Receive Amount: ₹${fuel.toReceiveAmount}"),
          ],
        );
      },
    );
  }

  Widget buildSalesList(List sales) {
    if (sales.isEmpty) return Text("No Sales");

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sales.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, index) {
        final sale = sales[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sales Date: ${sale.salesDate}"),
            Text("Crop Name: ${sale.cropName}"),
            Text("Total Sales Amount: ₹${sale.totalSalesAmount}"),
            Text("Amount Paid: ₹${sale.amountPaid}"),
            Text("Received Amount: ₹${sale.receivedAmount}"),
            Text("To Pay Amount: ₹${sale.toPayAmount}"),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer & Vendor Details')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.error.isNotEmpty) {
          return Center(child: Text('Error: ${controller.error.value}'));
        }

        final payables = controller.payables.value;
        final receivables = controller.receivables.value;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (detailsType == DetailsType.payables) ...[
                // You can similarly update payables section here if needed
                Text(
                  'Vendor Payables',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                payables == null || payables.vendorPayables.isEmpty
                    ? Text('No Vendor Payables')
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: payables.vendorPayables.length,
                      itemBuilder: (context, index) {
                   
                        return ListTile(title: Text('Vendor Payable #$index'));
                      },
                    ),

                SizedBox(height: 20),

                Text(
                  'Customer Payables',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                payables == null || payables.customerPayables.isEmpty
                    ? Text('No Customer Payables')
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: payables.customerPayables.length,
                      itemBuilder: (context, index) {
                    
                        return ListTile(
                          title: Text('Customer Payable #$index'),
                        );
                      },
                    ),
              ] else if (detailsType == DetailsType.receivables) ...[
                Text(
                  'Vendor Receivables',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                receivables == null || receivables.vendorReceivables.isEmpty
                    ? Text('No Vendor Receivables')
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: receivables.vendorReceivables.length,
                      itemBuilder: (context, index) {
                        final vendor = receivables.vendorReceivables[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    vendor.vendorImage.isNotEmpty
                                        ? Image.network(
                                          vendor.vendorImage,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey.shade300,
                                          child: Icon(Icons.person, size: 40),
                                        ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vendor.vendorName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(vendor.businessName),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                Text(
                                  "Fuel Receivables:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                buildFuelReceivablesList(
                                  vendor.fuelReceivables,
                                ),

                                // You can similarly display other receivable lists if needed
                                SizedBox(height: 12),
                                Text(
                                  "Seed Receivables: ${vendor.seedReceivables.length} items",
                                ),
                                Text(
                                  "Pesticide Receivables: ${vendor.pesticideReceivables.length} items",
                                ),
                                Text(
                                  "Fertilizer Receivables: ${vendor.fertilizerReceivables.length} items",
                                ),
                                Text(
                                  "Vehicle Receivables: ${vendor.vehicleReceivables.length} items",
                                ),
                                Text(
                                  "Machinery Receivables: ${vendor.machineryReceivables.length} items",
                                ),
                                Text(
                                  "Tool Receivables: ${vendor.toolReceivables.length} items",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                SizedBox(height: 20),

                Text(
                  'Customer Receivables',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                receivables == null || receivables.customerReceivables.isEmpty
                    ? Text('No Customer Receivables')
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: receivables.customerReceivables.length,
                      itemBuilder: (context, index) {
                        final customer = receivables.customerReceivables[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    customer.customerImage.isNotEmpty
                                        ? Image.network(
                                          customer.customerImage,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey.shade300,
                                          child: Icon(Icons.person, size: 40),
                                        ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            customer.customerName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(customer.shopName),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                Text(
                                  "Sales:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                buildSalesList(customer.sales),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
