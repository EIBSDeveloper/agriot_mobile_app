import 'package:argiot/src/app/modules/inventory/controller/inventory_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/loading.dart';
import '../../../widgets/title_text.dart';

class InventoryOverview extends GetView<InventoryController> {
  const InventoryOverview({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: () async {
        controller.loadInventory();
      },
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Loading();
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: TitleText("inventory".tr, fit: BoxFit.none),
            ),
            const SizedBox(height: 10),
            ...inventory.map(
              (item) => _buildInventoryItem(
                item.name,
                '${item.quantity?.round()} ${item.unitType}',
                item.id,
              ),
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

  Widget _buildInventoryItem(String title, String quantity, int id) => Column(
    children: [
      InkWell(
        onTap: () => controller.navigateToCategoryDetail(id),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withAlpha(50),
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
      ),
      const Divider(),
    ],
  );
}
