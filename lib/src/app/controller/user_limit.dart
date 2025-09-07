import 'package:argiot/src/app/modules/subscription/model/farmer_usage_response.dart';
import 'package:argiot/src/app/modules/subscription/model/package_usage.dart';
import 'package:get/get.dart';
import '../modules/subscription/repository/subscription_repository.dart';

class UserLimitController extends GetxController {
  final SubscriptionRepository repository = SubscriptionRepository();

  final Rx<FarmerUsageResponse?> usage = Rx<FarmerUsageResponse?>(null);
  final Rx<PackageUsage?> packageUsage = Rx<PackageUsage?>(null);
  @override
  void onInit() {
    super.onInit();
    loadUsage();
  }

  Future<void> loadUsage() async {
    try {
      final response = await repository.getFarmerUsage();
      usage.value = response;
      packageUsage.value = usage.value!.packageDetails;
    } catch (e) {
      print("object");
    }
  }
}
