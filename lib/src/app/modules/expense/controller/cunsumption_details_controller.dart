import 'package:argiot/src/app/modules/expense/model/fuel_inventory_model.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../repostroy/cunsumption_details_repository.dart';

class CunsumptionDetailsController extends GetxController {
  final CunsumptionDetailsRepository repository = CunsumptionDetailsRepository();

  final RxInt cunsumptionId = 0.obs;
  final RxInt inventoryType = 0.obs;

  final isLoading = true.obs;
  final fuelInventory = Rx<PurchaseDetailModel?>(null);
  final error = RxString('');

  @override
  void onInit() {
    super.onInit();
    cunsumptionId.value = Get.arguments['id'];
    inventoryType.value = Get.arguments['type'];
    loadCunsumptionDetail();
  }

  Future<void> loadCunsumptionDetail() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await repository.getCunsumptionDetail(
        cunsumptionId.value,
        inventoryType.value,
      );
      fuelInventory.value = result;
    } catch (e) {
      error.value = e.toString();
      showError('Failed to load fuel inventory details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteInventory() async {
    try {
      final confirmed = await showDeleteConfirmation();
      if (!confirmed) return;

      final success = await repository.deleteFuelInventory(cunsumptionId.value);
      if (success) {
        showSuccess('Fuel inventory deleted successfully');
        Get.back(result: true);
      }
    } catch (e) {
      showError('Failed to delete fuel inventory');
    }
  }

  Future<bool> showDeleteConfirmation() async =>
      await Get.dialog(
        AlertDialog(
          title: Text('confirm_delete'.tr),
          content: Text('delete_fuel_confirmation'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('delete'.tr),
            ),
          ],
        ),
      ) ??
      false;

  void navigateToEditScreen() {
    if (fuelInventory.value != null) {
      Get.toNamed('/edit_fuel', arguments: fuelInventory.value);
    }
  }

  void viewDocument(String documentUrl) {
    Get.toNamed( Routes.docViewer, arguments: documentUrl);
  }
}
