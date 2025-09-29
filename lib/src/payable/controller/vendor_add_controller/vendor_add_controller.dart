import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/modules/document/document.dart';

import '../../../app/service/utils/enums.dart';
import '../../../app/service/utils/utils.dart' show getDocTypeId;
import '../../repository/vendor_add_repository/vendor_add_repository.dart';

class VendorAddController extends GetxController {
  final VendorAddRepository repository;

  VendorAddController({required this.repository});

  var isLoading = false.obs;
  var error = "".obs;

  var payables = Rxn<dynamic>();
  var receivables = Rxn<dynamic>();
  void clearFiles() {
    documentItems.clear();
  }
  Future<void> addVendorPayable({
    required int vendorId,
    required int fuelPurchaseId,
    required String date, // keep as DD-MM-YYYY
    required double amount,
    required String description,
    required String type,
  }) async {
    isLoading.value = true;
    try {
      print(
        "Vendor Payable Data: $vendorId, $fuelPurchaseId, $date, $amount, $type, $description",
      );

      await repository.createVendorPayable(
        vendorId: vendorId,
        fuelPurchaseId: fuelPurchaseId,
        date: date, // send exactly as DD-MM-YYYY
        paymentAmount: amount,
        description: description,
        type: type,
        documentItems: documentItems,
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

  // Similarly for addVendorReceivable
  Future<void> addVendorReceivable({
    required int vendorId,
    required int fuelPurchaseId,
    required String date, // keep as DD-MM-YYYY
    required double amount,
    required String description,
    required String type,
  }) async {
    isLoading.value = true;
    try {
      print(
        "Vendor Receivable Data: $vendorId, $fuelPurchaseId, $date, $amount, $type, $description",
      );

      await repository.createVendorReceivable(
        vendorId: vendorId,
        fuelPurchaseId: fuelPurchaseId,
        date: date, // send as DD-MM-YYYY
        paymentAmount: amount,
        description: description,
        type: type,
        //documentItems: documentItems.map((e) => e.toJson()).toList(),
        documentItems: documentItems,
      );
    } finally {
      isLoading.value = false;
    }
  }

  final RxList<AddDocumentModel> documentItems = <AddDocumentModel>[].obs;

  void addDocumentItem() {
    Get.to(
      const AddDocumentView(),
      binding: DocumentBinding(),
      arguments: {"id": getDocTypeId(DocTypes.payouts)},
    )?.then((result) {
      if (result != null && result is AddDocumentModel) {
        documentItems.add(result);
      }
      print(documentItems.toString());
    });
  }

  void removeDocumentItem(int index) {
    documentItems.removeAt(index);
  }
}
