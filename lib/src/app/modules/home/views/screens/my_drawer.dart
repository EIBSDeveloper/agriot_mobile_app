import 'package:argiot/src/core/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../payable/pages/payables_receivables/payables_receivables_screen.dart';
import '../../../../routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primaryContainer.withAlpha(180),
          ),
          child: Column(
            children: [
              Image.asset(AppImages.logo, height: 80),
              const SizedBox(height: 10),
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _buildDrawerItem(
          icon: Icons.people,
          label: "employee_manager".tr,
          onTap: () {
            Get.back();
            Get.toNamed(Routes.employeeManager);
          },
        ),
        _buildDrawerItem(
          icon: Icons.fact_check,
          label: "Attendance",
          //onTap: () => Get.back(),
          onTap: () {
            Get.back();
            Get.toNamed(Routes.attendencelistscreen);
          },
        ),
        _buildDrawerItem(
          icon: Icons.payments,
          label: "add_advance".tr,
          onTap: () {
            Get.back();
            Get.toNamed(Routes.updateEmployeePayouts);
          },
        ), _buildDrawerItem(
          icon: Icons.account_balance_wallet,
          label: "Employee Payouts List",
          onTap: () {
            Get.back();
            Get.toNamed(Routes.payoutlistscreen);
          },
        ),

      
        const Divider(),
        _buildDrawerItem(
          icon: Icons.account_balance_wallet,
          label: "My Outstanding",
          onTap: () {
            Get.back();
            Get.to(const PayablesReceivablesPage());
          },
        ),

        _buildDrawerItem(
          icon: Icons.contacts,
          label: "My Contacts",
          onTap: () {
            Get.back();
            Get.toNamed(Routes.vendorCustomer);
          },
        ),

        // _buildDrawerItem(
        //   icon: Icons.data_exploration_outlined,
        //   label: "Sales",
        //   onTap: () {
        //     Get.back();
        //     Get.toNamed(Routes.sales);
        //   },
        // ),
        const Divider(),
        _buildDrawerItem(
          icon: Icons.store,
          label: "Markets",
          onTap: () {
            Get.back();
            Get.toNamed(Routes.nearMe);
          },
        ),
        const Divider(),
        _buildDrawerItem(
          icon: Icons.subscriptions,
          label: "Subscription",
          onTap: () {
            Get.back();
            Get.toNamed(Routes.subscriptionPlans);
          },
        ),
        const Divider(),
      ],
    ),
  );

  /// Reusable Drawer Item
  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) => ListTile(
    leading: Icon(icon, color: Get.theme.colorScheme.primary),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Get.theme.colorScheme.onSurface,
      ),
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: onTap,
  );
}
