// controller/customer_vendor_controller.dart

import 'package:get/get.dart';

import '../../model/customer_vendor_model/customer_vendor_model.dart';
import '../../repository/customer_vendor_repository/customer_vendor_repository.dart';

class CustomerVendorController extends GetxController {
  final CustomerVendorRepository repository;

  CustomerVendorController({required this.repository});

  var isLoading = false.obs;

  var payables = Rxn<PayablesData>();
  var receivables = Rxn<ReceivablesData>();

  var error = ''.obs;

  Future<void> loadPayables(int id) async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await repository.fetchPayables(id);
      payables.value = result.data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReceivables(int id) async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await repository.fetchReceivables(id);
      receivables.value = result.data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
