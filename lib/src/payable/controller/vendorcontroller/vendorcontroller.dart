import 'package:get/get.dart';

import '../../model/vendor/vendor_history_model.dart';
import '../../model/vendor/vendor_purchase_model.dart';
import '../../repository/vendor_repository/vendor_repository.dart';

class VendorPurchaseController extends GetxController {
  final VendorPurchaseRepository repository;

  VendorPurchaseController({required this.repository});

  // Loading & error
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Current Payables & Receivables
  var vendorPayables = <VendorPayable>[].obs;
  var vendorReceivables = <VendorPayable>[].obs;

  // History
  var vendorPayablesHistory = <VendorPayableHistoryModel>[].obs;
  var vendorReceivablesHistory = <VendorReceivableHistoryModel>[].obs;

  // Load Payables
  Future<void> loadVendorPayables( int vendorId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.fetchVendorPayables( vendorId);
      vendorPayables.value = response.vendorInventoryData.payables ?? [];
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }

  // Load Receivables
  Future<void> loadVendorReceivables(int vendorId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.fetchVendorReceivables(vendorId);
      vendorReceivables.value = response.vendorInventoryData.receivables ?? [];
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }

  // Load Payables History
  Future<void> loadVendorPayablesHistory({
    required int vendorId,
    required String type,
    required int fuelId,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final List<VendorPayableHistoryModel>? response = await repository
          .fetchVendorPayablesHistory(
            vendorId: vendorId,
            fuelId: fuelId,
            type: type,
          );

      // Directly assign the list
      vendorPayablesHistory.value = response ?? [];
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }

  //Load Receivables History
  Future<void> loadVendorReceivablesHistory({
    required int vendorId,
    required int fuelId,
    required String type,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final List<VendorReceivableHistoryModel>? response = await repository
          .fetchVendorReceivablesHistory(
            vendorId: vendorId,
            fuelId: fuelId,
            type: type,
          );

      // Directly assign the list
      vendorReceivablesHistory.value = response ?? [];
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }
}
