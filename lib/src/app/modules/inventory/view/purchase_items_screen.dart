// lib/modules/expenses/models/expense_model.dart
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../controller/inventory_controller.dart';

class PurchaseItemsScreen extends GetView<InventoryController> {
  const PurchaseItemsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'add_purchase'.tr),
    body: RefreshIndicator(
      onRefresh: () async {
        controller.loadInventory();
      },
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        final inventory = controller.inventory.value;
        if (inventory == null) {
          return Center(child: Text('no_inventory_data'.tr));
        }

        return ListView(
          children: [
            ...inventory.map(
              (item) => _buildInventoryItem(
                item.name,
                '${item.quantity?.round()} ${item.unitType}',
                open: () {
                  controller.navigateToCategoryDetail(item.id, tab: 1);
                },
                onTap: () {
                  if (item.id == 6) {
                    Get.toNamed(
                      '/fuel-expenses-entry',
                      arguments: {"id": item.id},
                    )?.then((res) {
                      controller.loadInventory();
                    });
                  } else if (item.id == 1) {
                    Get.toNamed(
                      '/vehicle_entry',
                      arguments: {"id": item.id},
                    )?.then((res) {
                      if (res ?? false) {
                        controller.loadInventory();
                      }
                    });
                  } else if (item.id == 2) {
                    Get.toNamed(
                      '/machinery_entry',
                      arguments: {"id": item.id},
                    )?.then((res) {
                      if (res ?? false) {
                        controller.loadInventory();
                      }
                    });
                  } else  {
                    Get.toNamed(
                      '/fertilizer_entry',
                      arguments: {"id": item.id},
                    )?.then((res) {
                      if (res ?? false) {
                        controller.loadInventory();
                      }
                    });
                  } 
                },
              ),
            ),
           _buildInventoryItem(
              "general_expense".tr,
              '',
              open: () {},
              onTap: () {
                Get.toNamed(Routes.addExpense)?.then((res) {});
              },
            ),
          ],
        );
      }),
    ),
  );

  Widget _buildInventoryItem(
    String title,
    String quantity, {
    Function()? onTap,
    Function()? open,
  }) => Column(
    children: [
      InkWell(
        onTap: open,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title Text
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Quantity with tap handler (open)
              // if (quantity.isNotEmpty)
              InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Text(
                      // quantity.isNotEmpty?  '($quantity)  ':'',
                      //   style: TextStyle(
                      //     color: Colors.green.shade700,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      Icon(Icons.add, color: Colors.green.shade700),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const Divider(),
    ],
  );
}
