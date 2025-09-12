import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controller/sales_controller.dart';

class SalesListView extends GetView<SalesController> {
  const SalesListView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Sales List', showBackButton: true),
    body: RefreshIndicator(
      onRefresh: () async {
        await controller.fetchSalesList();
      },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // SizedBox(height: 18,),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: InputCardStyle(
                      child: Column(
                        children: [
                          const FittedBox(
                            child: Text(
                              "Total Sales ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputCardStyle(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedPeriod.value,
                          padding: EdgeInsets.zero,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),

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
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputCardStyle(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: controller.selectedCropType.value,
                          isExpanded: true,

                          icon: const Icon(Icons.keyboard_arrow_down),
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
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: controller.salesList.length,
                  itemBuilder: (context, index) {
                    final group = controller.salesList[index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            // horizontal: 16,
                            vertical: 16,
                          ),
                          child: Text(
                            group.date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // 🔹 Sales Cards for this date
                        ...group.sales.map(
                          (sale) => Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            elevation: 1,
                            child: ListTile(
                              title: Text(
                                sale.myCustomer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sale Quantity : ${sale.salesQuantity}'),
                                ],
                              ),
                              trailing: Text(
                                '₹${sale.totalSalesAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Get.theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () => Get.toNamed(
                                Routes.salesDetails,
                                arguments: {'id': sale.salesId},
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    ),

    floatingActionButton: FloatingActionButton(
      backgroundColor: Get.theme.primaryColor,
      child: const Icon(Icons.add),
      onPressed: () =>
          Get.toNamed(Routes.newSales, arguments: {"new": true})?.then((yy) {
            controller.fetchSalesList();
          }),
    ),
  );
}
