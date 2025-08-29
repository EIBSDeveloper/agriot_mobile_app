import 'package:argiot/src/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            Text(
              'payment_successful'.tr,
              style: Get.textTheme.headlineMedium?.copyWith(
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'payment_success_message'.tr,
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(
                  Routes.home,
                ); // Replace with your dashboard route
              },
              child: Text('continue_to_dashboard'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
