import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/core/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../payable/pages/payables_receivables/payables_receivables_screen.dart';
import '../../../../routes/app_routes.dart';
import '../../../../service/utils/pop_messages.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});
  final AppDataController appDeta = Get.find();
  @override
  Widget build(BuildContext context) => Drawer(
    child: Column(
      children: [
        Expanded(
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (appDeta.permission.value?.employee?.list != 0)
                _buildDrawerItem(
                  icon: Icons.people,
                  label: "employee_manager".tr,
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.employeeManager);
                  },
                ),
              if (appDeta.permission.value?.attendance?.list != 0)
                _buildDrawerItem(
                  icon: Icons.fact_check,
                  label: "Attendance",
                  //onTap: () => Get.back(),
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.attendencelistscreen);
                  },
                ),
              if (appDeta.permission.value?.advance?.list != 0)
                _buildDrawerItem(
                  icon: Icons.payments,
                  label: "add_advance".tr,
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.updateEmployeePayouts);
                  },
                ),
              if (appDeta.permission.value?.advance?.list != 0)
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet,
                  label: "Employee Payouts List",
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.payoutlistscreen);
                  },
                ),

              const Divider(),
              if (appDeta.permission.value?.payouts?.list != 0)
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet,
                  label: "My Outstanding",
                  onTap: () {
                    Get.back();
                    Get.to(const PayablesReceivablesPage());
                  },
                ),
              if (appDeta.permission.value?.vendor?.list != 0)
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
              // const Divider(),
              _buildDrawerItem(
                icon: Icons.store,
                label: "Near me",
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.nearMe);
                },
              ),
             const Divider(),  
             if (!appDeta.isManager.value)
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
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: Text('logout'.tr),
            onPressed: () => _showLogoutConfirmation(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(color: Colors.red.shade400),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> logout() async {
    try {
      // isLoading.value = true;

      // signOutFromGoogle();
      await GetStorage().erase();
      appDeta.farmerId.value = '';
      appDeta.username.value = '';
      appDeta.emailId.value = '';
      appDeta.isManager.value = false;
      appDeta.managerID.value = '';
      appDeta.permission.value = null;
      Get.offAllNamed(Routes.login);
    } catch (e) {
      showError('Failed to logout');
    } finally {
      // isLoading.value = false;
    }
  }

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
