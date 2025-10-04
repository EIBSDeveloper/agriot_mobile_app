import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/subscription/model/package.dart';
import 'package:argiot/src/app/modules/subscription/controller/subscription_controller.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../widgets/loading.dart';


class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'payment'.tr),
      body: Obx(() {
        final selectedPackage = controller.selectedPackage.value;
        if (selectedPackage == null) {
          return Center(child: Text('no_package_selected'.tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('selected_plan'.tr, style: Get.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            selectedPackage.name,
                            style: Get.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${selectedPackage.formattedPrice} • ${selectedPackage.durationText}',
                            style: Get.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'payment_summary'.tr,
                        style: Get.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentRow(
                        'plan_price'.tr,
                        selectedPackage.formattedPrice,
                      ),
                      if (selectedPackage.offer &&
                          selectedPackage.subAmount != null)
                        _buildPaymentRow(
                          'discount'.tr,
                          '-${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(selectedPackage.amount - selectedPackage.subAmount!)}',
                        ),
                      const Divider(),
                      _buildPaymentRow(
                        'total_amount'.tr,
                        selectedPackage.subAmount != null
                            ? NumberFormat.currency(
                                symbol: '₹',
                                decimalDigits: 0,
                              ).format(selectedPackage.subAmount)
                            : selectedPackage.formattedPrice,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (controller.isLoading.value)
                const Loading(size:50)
              else
                ElevatedButton(
                  onPressed: () =>
                      _initiatePayment(controller, selectedPackage),
                  child: Text('proceed_to_payment'.tr),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Get.textTheme.titleMedium
                : Get.textTheme.bodyLarge,
          ),
          Text(
            value,
            style: isTotal
                ? Get.textTheme.titleMedium
                : Get.textTheme.bodyLarge,
          ),
        ],
      ),
    );

  Future<void> _initiatePayment(
    SubscriptionController controller,
    Package package,
  ) async {
    try {
      // Create order
      final order = await controller.repository.createOrder(
        20 * 100,
      );

      // Initialize Razorpay
      final razorpay = Razorpay();
      razorpay.on(
        Razorpay.EVENT_PAYMENT_SUCCESS,
        controller.handlePaymentSuccess,
      );
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, controller.handlePaymentError);
      razorpay.on(
        Razorpay.EVENT_EXTERNAL_WALLET,
        controller.handleExternalWallet,
      );

      // Open payment dialog
      final options = {
        'key': order.keyId,
        'name': 'AgriTech App',
        'description': package.name,
        'order_id': order.orderId,
        'theme': {
          'color':Get.theme.colorScheme.primary.toARGB32().toRadixString(16)
,
        },
      };

      razorpay.open(options);
    } catch (e) {
     showError(
        'error'.tr,
       
      );
    }
  }
}
