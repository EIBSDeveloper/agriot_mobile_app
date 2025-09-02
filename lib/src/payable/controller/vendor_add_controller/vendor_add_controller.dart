import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../repository/vendor_add_repository/vendor_add_repository.dart';

class VendorAddController extends GetxController {
  final VendorAddRepository repository;

  VendorAddController({required this.repository});

  var isLoading = false.obs;
  var error = "".obs;

  var payables = Rxn<dynamic>();
  var receivables = Rxn<dynamic>();

  // Add Vendor Payable
  Future<void> addVendorPayable({
    required int vendorId,
    required int fuelPurchaseId,
    required String date,
    required double amount,
    required String description,
    required String type,
  }) async {
    isLoading.value = true;

    try {
      await repository.createVendorPayable(
        vendorId: vendorId,
        fuelPurchaseId: fuelPurchaseId,
        date: date,
        type: type,
        paymentAmount: amount,
        description: description,
      );

      Get.snackbar(
        "Success",
        "Payment Created Successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Add Vendor Receivable
  Future<void> addVendorReceivable({
    required int vendorId,
    required int fuelPurchaseId,
    required String date,
    required double amount,
    required String description,
    required String type,
  }) async {
    isLoading.value = true;

    try {
      final response = await repository.createVendorReceivable(
        vendorId: vendorId,
        fuelPurchaseId: fuelPurchaseId,
        date: date,
        type: type,
        paymentAmount: amount,
        description: description,
      );

      Get.snackbar(
        "Success",
        "Payment Received Successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
