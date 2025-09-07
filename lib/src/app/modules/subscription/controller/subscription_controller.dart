import 'package:argiot/src/app/modules/subscription/model/farmer_usage_response.dart';
import 'package:argiot/src/app/modules/subscription/model/package.dart';
import 'package:argiot/src/app/modules/subscription/model/package_list_response.dart';

import 'package:argiot/src/app/modules/subscription/repository/subscription_repository.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../profile/controller/profile_controller.dart';

class SubscriptionController extends GetxController {
  final SubscriptionRepository repository = SubscriptionRepository();
  final Rx<PackageListResponse?> packages = Rx<PackageListResponse?>(null);
  final Rx<FarmerUsageResponse?> usage = Rx<FarmerUsageResponse?>(null);
  final Rx<Package?> selectedPackage = Rx<Package?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  SubscriptionController();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.wait([loadPackages(), loadUsage()]);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPackages() async {
    try {
      final response = await repository.getPackages();
      packages.value = response;

      // Select the currently used package by default
      if (usage.value != null) {
        final currentPackageName = usage.value!.packageDetails.name;
        selectedPackage.value = packages.value?.packages.firstWhere(
          (p) => p.name == currentPackageName,
          orElse: () => packages.value!.packages.first,
        );
      } else {
        selectedPackage.value = packages.value?.packages.first;
      }
    } catch (e) {
      throw Exception('Failed to load packages: ${e.toString()}');
    }
  }

  Future<void> loadUsage() async {
    try {
      final response = await repository.getFarmerUsage();
      usage.value = response;
    } catch (e) {
      throw Exception('Failed to load usage: ${e.toString()}');
    }
  }

  void selectPackage(Package package) {
    selectedPackage.value = package;
  }

  Future<void> proceedToPayment() async {
    if (selectedPackage.value == null) throw Exception('No package selected');
  }

  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    isLoading.value = true;
    try {
      await repository.verifyPayment(
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
        packageId: selectedPackage.value!.id,
      );
      // Refresh data after successful payment
      ProfileController profile = Get.find();
      await profile.fetchProfile();
      // await loadData();
      Get.back();
      Get.back();
    } catch (e) {
      errorMessage.value = 'Payment verification failed: ${e.toString()}';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  void handlePaymentError(PaymentFailureResponse response) {
    errorMessage.value =
        'Payment failed: ${response.message ?? 'Unknown error'}';
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    errorMessage.value =
        'External wallet selected: ${response.walletName ?? 'Unknown wallet'}';
  }
}
