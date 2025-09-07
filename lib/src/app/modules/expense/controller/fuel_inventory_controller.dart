import 'package:argiot/src/app/modules/expense/repostroy/fuel_inventory_repository.dart';
import 'package:argiot/src/app/modules/expense/model/fuel_inventory_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class FuelInventoryController extends GetxController {
  final FuelInventoryRepository repository = FuelInventoryRepository();

  final RxInt fuelId = 0.obs;

  final isLoading = true.obs;
  final fuelInventory = Rx<FuelInventoryModel?>(null);
  final error = RxString('');

  @override
  void onInit() {
    super.onInit();
    fuelId.value = Get.arguments['id'];
    loadFuelInventoryDetail();
  }

  Future<void> loadFuelInventoryDetail() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await repository.getFuelInventoryDetail(fuelId.value);
      fuelInventory.value = result;
    } catch (e) {
      error.value = e.toString();
      Fluttertoast.showToast(
        msg: 'Failed to load fuel inventory details',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteInventory() async {
    try {
      final confirmed = await showDeleteConfirmation();
      if (!confirmed) return;

      final success = await repository.deleteFuelInventory(fuelId.value);
      if (success) {
        Fluttertoast.showToast(
          msg: 'Fuel inventory deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        Get.back(result: true);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to delete fuel inventory',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<bool> showDeleteConfirmation() async => await Get.dialog(
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
    Get.toNamed('/document_viewer', arguments: documentUrl);
  }
}
