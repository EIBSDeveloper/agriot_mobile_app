// lib/app/modules/guidelines/models/inventory_model.dart

import 'package:argiot/src/app/modules/inventory/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/title_text.dart';

class InventoryOverview extends GetView<InventoryController> {
  const InventoryOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TitleText("inventory".tr, fit: BoxFit.none),
              ),
              SizedBox(height: 10),
              _buildInventoryItem(
                'fuel'.tr,
                '${inventory.fuel.totalQuantity.round()} Ltr',
                inventory.fuel.id,
              ),
              const Divider(),
              _buildInventoryItem(
                'vehicle'.tr,
                '${inventory.vehicle.totalFuelCapacity.round()}',
                inventory.vehicle.id,
              ),
              const Divider(),
              _buildInventoryItem(
                'machinery'.tr,
                '${inventory.machinery.totalFuelCapacity.round()}',
                inventory.machinery.id,
              ),
              const Divider(),
              _buildInventoryItem(
                'tools'.tr,
                '${inventory.tools.totalQuantity.round()}',
                inventory.tools.id,
              ),
              const Divider(),
              _buildInventoryItem(
                'pesticides'.tr,
                '${inventory.pesticides.totalQuantity.round()} kg',
                inventory.pesticides.id,
              ),
              const Divider(),
              _buildInventoryItem(
                'fertilizers'.tr,
                '${inventory.fertilizers.totalQuantity.round()} kg',
                inventory.fertilizers.id,
              ),
              const Divider(),
              _buildInventoryItem(
                'seeds'.tr,
                '${inventory.seeds.totalQuantity.round()} kg',
                inventory.seeds.id,
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        onPressed: controller.navigateToAddInventory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryItem(String title, String quantity, int id) {
    return InkWell(
      onTap: () => controller.navigateToCategoryDetail(title.toLowerCase(), id),
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
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
              child: Text(
                "$quantity ",
                style: TextStyle(
                  color: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
