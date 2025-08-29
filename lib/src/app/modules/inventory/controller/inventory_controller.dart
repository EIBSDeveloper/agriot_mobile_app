// lib/app/modules/guidelines/models/inventory_model.dart

import 'package:argiot/src/app/modules/inventory/model/inventory_model.dart';
import 'package:argiot/src/app/modules/inventory/repostory/inventory_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../controller/user_limit.dart';
import '../../subscription/package_model.dart';

class InventoryController extends GetxController {
  final InventoryRepository _repository = InventoryRepository();
  UserLimitController usage = Get.find();
  final Rx<InventoryModel?> inventory = Rx<InventoryModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInventory();
  }

  Future<void> loadInventory() async {
    try {
      isLoading(true);
      errorMessage('');
      final result = await _repository.getInventory();
      inventory(result);
    } catch (e) {
      errorMessage(e.toString());
      Fluttertoast.showToast(
        msg: "Failed to load inventory: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
     
      );
    } finally {
      isLoading(false);
    }
  }

  void navigateToAddInventory() {
 PackageUsage packageDetails2 = usage.usage.value!.packageDetails;
packageDetails2.landBalance;
    Get.toNamed('/add-inventory');
  }

  void navigateToCategoryDetail(String category) {
    // Implement navigation to category detail if needed
  }
}
