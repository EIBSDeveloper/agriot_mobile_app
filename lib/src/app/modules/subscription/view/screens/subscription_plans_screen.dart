import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/subscription/model/package.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/modules/subscription/controller/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/title_text.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'subscription_plans'.tr),
      body: Obx(() {
        if (controller.isLoading.value && controller.packages.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(controller.errorMessage.value),
                ),
                ElevatedButton(
                  onPressed: controller.loadData,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        final packages = controller.packages.value;
        if (packages == null || packages.packages.isEmpty) {
          return Center(child: Text('no_packages_available'.tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              ...packages.packages.map(
                (package) => _buildPackageCard(
                  package,
                  isSelected:
                      package.id == controller.selectedPackage.value?.id,
                  onSelect: () => controller.selectPackage(package),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Obx(
          () => ElevatedButton(
            onPressed: controller.selectedPackage.value != null
                ? () => Get.toNamed(Routes.subscriptionPayment)
                : null,
            child: Text('proceed_to_payment'.tr),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(
    Package package, {
    bool isSelected = false,
    VoidCallback? onSelect,
  }) => Card(
    margin: const EdgeInsets.only(bottom: 16),

    color: isSelected ? Get.theme.colorScheme.primary : null,
    child: InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleText(
                  package.name,
                  color: isSelected ? Colors.white : null,
                ),
                RadioGroup(
                  groupValue: isSelected ? package : null,
                  onChanged: (p) => onSelect?.call(),
                  child: Radio<Package>(
                    value: package,

                    activeColor: isSelected
                        ? Get.theme.colorScheme.onPrimary
                        : Get.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${package.formattedPrice} • ${package.durationText}',
              style: Get.textTheme.titleMedium?.copyWith(
                color: isSelected ? Get.theme.colorScheme.onPrimary : null,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildFeatureList(package, isSelected),
          ],
        ),
      ),
    ),
  );
  // {

  List<Widget> _buildFeatureList(Package package, bool isSelected) {
    final textColor = isSelected ? Get.theme.colorScheme.onPrimary : null;

    return [
      _buildFeatureItem(
        'land_management'.tr,
        package.myLandCount,
        package.myLandCount > 0,
        textColor,
      ),
      _buildFeatureItem(
        'crops_management'.tr,
        package.myCropsCount,
        package.myCropsCount > 0,
        textColor,
      ),
      _buildFeatureItem(
        'expense_tracking'.tr,
        package.myExpenseCount,
        package.myExpenseCount > 0,
        textColor,
      ),
      _buildFeatureItem(
        'sales_tracking'.tr,
        package.mySaleCount,
        package.mySaleCount > 0,
        textColor,
      ),
      _buildFeatureItem(
        'customer_management'.tr,
        package.customerCount,
        package.customerCount > 0,
        textColor,
      ),
      _buildFeatureItem(
        'vehicle_management'.tr,
        package.myVechicleCount,
        package.isMyVechicle,
        textColor,
      ),
      _buildFeatureItem(
        'machinery_management'.tr,
        package.myMachineryCount,
        package.isMymachinery,
        textColor,
      ),
      _buildFeatureItem(
        'tools_management'.tr,
        package.mytoolsCount,
        package.isMytools,
        textColor,
      ),
      _buildFeatureItem(
        'inventory_products'.tr,
        package.myinventoryProducts,
        package.isMyinventory,
        textColor,
      ),
      _buildFeatureItem(
        'inventory_purchases'.tr,
        package.myinventoryPurchase,
        package.isMyinventory,
        textColor,
      ),
      _buildFeatureItem(
        'inventory_vendors'.tr,
        package.myinventoryVendors,
        package.isMyinventory,
        textColor,
      ),
      _buildFeatureItem(
        'employee_attendance'.tr,
        package.employeeCount,
        package.isAttendance,
        textColor,
      ),
      _buildFeatureItem(
        'payouts'.tr,
        package.isPayouts ? 1 : 0,
        package.isPayouts,
        textColor,
      ),
      _buildFeatureItem(
        'widgets'.tr,
        package.isWidget ? 1 : 0,
        package.isWidget,
        textColor,
      ),
      _buildFeatureItem(
        'using_package'.tr,
        package.isUsingPackage ? 1 : 0,
        package.isUsingPackage,
        textColor,
      ),
    ];
  }

  Widget _buildFeatureItem(
    String title,
    int limit,
    bool isAvailable,
    Color? textColor,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(
          isAvailable ? Icons.check_circle : Icons.cancel,
          color: isAvailable ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: TextStyle(color: textColor)),
        ),
        Text(limit.toString(), style: TextStyle(color: textColor)),
      ],
    ),
  );
}
