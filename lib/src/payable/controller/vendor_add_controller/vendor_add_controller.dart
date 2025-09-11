import 'package:get/get.dart';

import '../../../app/service/utils/utils.dart';
import '../../repository/vendor_add_repository/vendor_add_repository.dart';

class VendorAddController extends GetxController {
  final VendorAddRepository repository;

  VendorAddController({required this.repository});

  var isLoading = false.obs;
  var error = "".obs;

  var payables = Rxn<dynamic>();
  var receivables = Rxn<dynamic>();

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
      );

    showSuccess(
        "Payment Created Successfully",
      
      );
    } catch (e) {
      showError(
        e.toString(),
      
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
      );

  showSuccess(
        "Payment Received Successfully",
      
      );
    } catch (e) {
     showError(
        e.toString(),
        
      );
    } finally {
      isLoading.value = false;
    }
  }
}
