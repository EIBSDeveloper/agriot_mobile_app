import 'package:get/get.dart';
import '../modules/subscription/package_model.dart';
import '../modules/subscription/subscription_repository.dart';

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
      // if(usage.value!.packageDetails.)
    // ignore: empty_catches
    } catch (e) {

    }
  }
}
