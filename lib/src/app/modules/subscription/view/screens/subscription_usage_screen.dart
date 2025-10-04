import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/modules/subscription/controller/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';

class SubscriptionUsageScreen extends StatelessWidget {
  const SubscriptionUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'current_subscription'.tr),
      body: Obx(() {
        if (controller.isLoading.value ) {
          return const Loading();
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

        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,

                  child: Padding(
                    padding: const EdgeInsets.all(10),
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
                          'manager_limit'.tr,
                          packageUsage.employeeCount,
                          packageUsage.employeeCountUsed,
                        ),
                       
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          Get.toNamed(Routes.subscriptionPlans)?.then((result) {
                            // if (result ?? false) {
                              controller.loadData();
                            // }
                          }),
                      child: Text('view_subscription_plans'.tr),
                    ),
                  ],
                ),
              ],
            ),
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
      children: [Text(title), Text('${(total > used) ? total - used : 0} ')],
    ),
  );
}
