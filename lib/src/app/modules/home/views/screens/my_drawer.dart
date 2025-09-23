import 'package:argiot/src/core/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../payable/pages/payables_receivables/payables_receivables_screen.dart';
import '../../../../routes/app_routes.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

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
              // Replace with your app logo asset
              Image.asset(
                AppImages.logo, // make sure to add your logo here
                height: 80,
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome',
                style: TextStyle(
                  // color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.people_alt, color: Get.theme.primaryColor),
          title: const Text('User Management'),
          onTap: () {
            // Navigate to User Management screen
            Navigator.pop(context);
            // Add your navigation code here
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.check_circle, color: Get.theme.primaryColor),
          title: const Text('Attendance'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to Attendance screen
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.payment, color: Get.theme.primaryColor),
          title: const Text('Employee Payouts'),
          onTap: () {
            Navigator.pop(context);
            // Navigate to Qequler Payout screen
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.currency_rupee, color: Get.theme.primaryColor),
          title: const Text('My Outstanding'),
          onTap: () {
            Navigator.pop(context);
            Get.to(const PayablesReceivablesPage());
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.account_circle, color: Get.theme.primaryColor),
          title: const Text('My Contects'),
          onTap: () {
            Navigator.pop(context);
            Get.toNamed(Routes.vendorCustomer);
          },
        ),
        const Divider(),
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.sell,
            color: Get.theme.primaryColor,
          ), // Icon for Sales
          title: const Text('Sales'),
          onTap: () {
            Navigator.pop(context);
            // Get.to(const SalesPage());  // Navigate to Sales page
          },
        ),

        const Divider(),
        ListTile(
          leading: Icon(
            Icons.storefront,
            color: Get.theme.primaryColor,
          ), // Icon for Markets
          title: const Text('Markets'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.payment,
            color: Get.theme.primaryColor,
          ), // Icon for Subscription
          title: const Text('Subscription'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
