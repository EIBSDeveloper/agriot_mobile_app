import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../controller/controller.dart';

class SalesListView extends GetView<SalesController> {
  const SalesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales List')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // SizedBox(height: 18,),
            Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: AppStyle.decoration,
                      child: Column(
                        children: [
                          FittedBox(
                            child: Text(
                              "Total Expenses ",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            "₹ ${controller.totalSalesAmount}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: AppStyle.decoration,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedPeriod.value,
                          isExpanded: true,
                          items: ['week', 'month', 'year']
                              .map(
                                (period) => DropdownMenuItem(
                                  value: period,
                                  child: FittedBox(child: Text(period.tr)),
                                ),
                              )
                              .toList(),
                          onChanged: controller.changePeriod,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: AppStyle.decoration,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: controller.selectedCropType.value,
                          isExpanded: true,
                          items: controller.crop
                              .map(
                                (period) => DropdownMenuItem(
                                  value: period,
                                  child: Text(period.name),
                                ),
                              )
                              .toList(),
                          onChanged: (land) => controller.changeCrop(land!),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Grouped sales list
                final groupedSales = controller.salesList; // List<SalesByDate>

                return ListView.builder(
                  itemCount: groupedSales.length,
                  itemBuilder: (context, index) {
                    final group = groupedSales[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 Date Heading
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            group.date,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        // 🔹 Sales Cards for this date
                        ...group.sales.map((sale) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(sale.myCustomer.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Village: ${sale.myCustomer.village}'),
                                  Text(
                                    'Total: ₹${sale.totalSalesAmount.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Get.toNamed(
                              Routes.SALES_DETAILS,
                                arguments: {'id': sale.salesId},
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => Get.toNamed(Routes.NEW_SALES),
      ),
    );
  }
}
