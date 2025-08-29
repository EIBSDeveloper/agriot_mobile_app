import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';


class SalesDetailView extends GetView<SalesController> {
  const SalesDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (controller.salesDetail.value != null) {
                controller.initEditForm(controller.salesDetail.value!);
                Get.toNamed('/sales/edit', arguments: {
                  'sales_id': controller.salesDetail.value!.salesId,
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (controller.salesDetail.value != null) {
                Get.defaultDialog(
                  title: 'Confirm Delete',
                  content: const Text('Are you sure you want to delete this sale?'),
                  confirm: TextButton(
                    onPressed: () {
                      Get.back();
                      controller.deleteSales(controller.salesDetail.value!.salesId);
                    },
                    child: const Text('Delete'),
                  ),
                  cancel: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final detail = controller.salesDetail.value;
        if (detail == null) {
          return const Center(child: Text('No details available'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer: ${detail.myCustomer.name}',
                style: Get.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text('Date: ${detail.datesOfSales}'),
              Text('Crop: ${detail.myCrop.name}'),
              Text('Quantity: ${detail.salesQuantity} ${detail.salesUnit.name}'),
              Text('Amount per unit: ₹${detail.quantityAmount}'),
              Text('Total amount: ₹${detail.totalAmount}'),
              Text('Deductions: ₹${detail.deductionAmount}'),
              Text('Net amount: ₹${detail.totalSalesAmount.toStringAsFixed(2)}'),
              Text('Amount paid: ₹${detail.amountPaid.toStringAsFixed(2)}'),
              if (detail.description?.isNotEmpty ?? false)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Description: ${detail.description}'),
                  ],
                ),
              const SizedBox(height: 16),
              const Text(
                'Deductions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...detail.deductions.map((deduction) => ListTile(
                title: Text(deduction.reason?.name ?? 'Custom Reason'),
                subtitle: Text('Amount: ₹${deduction.charges} (${deduction.rupee.name})'),
              )),
              const SizedBox(height: 16),
              const Text(
                'Documents',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...detail.documents.expand((category) => category.documents).map(
                (document) => ListTile(
                  title: Text(document.documentCategory.name),
                  subtitle: Text(document.fileUpload),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      // Open document in browser or viewer
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}