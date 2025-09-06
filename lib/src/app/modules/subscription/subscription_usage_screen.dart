import 'package:argiot/src/routes/app_routes.dart';
import 'package:argiot/src/app/modules/subscription/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionUsageScreen extends StatelessWidget {
  const SubscriptionUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('current_subscription'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.usage.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                ElevatedButton(
                  onPressed: controller.loadData,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        final usage = controller.usage.value;
        if (usage == null) {
          return Center(child: Text('no_usage_data'.tr));
        }

        final packageUsage = usage.packageDetails;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${'hello'.tr}, ${usage.name}',
                style: Get.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        packageUsage.name,
                        style: Get.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildUsageItem(
                        'land_limit'.tr,
                        packageUsage.landCountUsed,
                        packageUsage.mylandCount,
                      ),
                      _buildUsageItem(
                        'crops_limit'.tr,
                        packageUsage.cropCountUsed,
                        packageUsage.mycropsCount,
                      ),
                      _buildUsageItem(
                        'expense_limit'.tr,
                        packageUsage.expenseCountUsed,
                        packageUsage.myexpenseCount,
                      ),
                      _buildUsageItem(
                        'sales_limit'.tr,
                        packageUsage.salesCountUsed,
                        packageUsage.mysaleCount,
                      ),
                      _buildUsageItem(
                        'customer_limit'.tr,
                        packageUsage.customerCountUsed,
                        packageUsage.customerCount,
                      ),
                      _buildUsageItem(
                        'fuel_limit'.tr,
                        packageUsage.myfuelCountUsed,
                        packageUsage.myfuelCount,
                      ),
                      _buildUsageItem(
                        'vehicle_limit'.tr,
                        packageUsage.myvehicleCountUsed,
                        packageUsage.myvechicleCount,
                      ),
                      _buildUsageItem(
                        'machinery_limit'.tr,
                        packageUsage.mymachineryCountUsed,
                        packageUsage.mymachineryCount,
                      ),
                      _buildUsageItem(
                        'tools_limit'.tr,
                        packageUsage.mytoolsCountUsed,
                        packageUsage.mytoolsCount,
                      ),
                      _buildUsageItem(
                        'pesticides_limit'.tr,
                        packageUsage.mypesticidesCountUsed,
                        packageUsage.mypesticidesCount,
                      ),
                      _buildUsageItem(
                        'fertilizers_limit'.tr,
                        packageUsage.myfertilizersCountUsed,
                        packageUsage.myfertilizersCount,
                      ),
                      _buildUsageItem(
                        'seeds_limit'.tr,
                        packageUsage.myseedsCountUsed,
                        packageUsage.myseedsCount,
                      ),
                      _buildUsageItem(
                        'inventory_vendors_limit'.tr,
                        packageUsage.myvendorCountUsed,
                        packageUsage.myinventoryVendors,
                      ),
                      _buildUsageItem(
                        'employee_limit'.tr,
                        packageUsage.employeeCountUsed,
                        packageUsage.employeeCount,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.subscriptionPlans),
                child: Text('view_subscription_plans'.tr),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUsageItem(String title, int used, int total) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), Text('${(total>used)?total-used:0} ')],
      ),
    );
}
