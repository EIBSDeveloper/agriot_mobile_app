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
  var vendorPayables = Rxn<Vendormodel>();
  var vendorReceivables = Rxn<Vendormodel>();

  // History
  var vendorPayablesHistory = <VendorHistoryModel>[].obs;
  var vendorReceivablesHistory = <VendorHistoryModel>[].obs;

  Future<void> loadVendorPayables(int vendorId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.fetchVendorPayables(vendorId);
      vendorPayables.value = response; // 👈 directly from same model
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }

  Future<void> loadVendorReceivables(int vendorId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.fetchVendorReceivables(vendorId);
      vendorReceivables.value = response;
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }

  // Payables
  Future<void> loadVendorPayablesHistory(int expenseId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.fetchVendorPayablesHistory(expenseId);
      vendorPayablesHistory.value = response;
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }

  // Receivables
  Future<void> loadVendorReceivablesHistory(int expenseId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await repository.fetchVendorReceivablesHistory(
        expenseId,
      );
      vendorReceivablesHistory.value = response;
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }
}
