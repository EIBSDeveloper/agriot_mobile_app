import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 100),
          const SizedBox(height: 24),
          Text(
            'payment_failed'.tr,
            style: Get.textTheme.headlineMedium?.copyWith(color: Colors.red),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'payment_failed_message'.tr,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Get.back(),
                child: Text('back'.tr),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Get.offAllNamed(Routes.subscriptionPlans),
                child: Text('try_again'.tr),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
