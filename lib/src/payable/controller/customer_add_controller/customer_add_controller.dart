import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../app/service/utils/utils.dart';
import '../../repository/customer_add_repository/customer_add_repository.dart';

class CustomerAddController extends GetxController {
  final CustomerAddRepository repository;

  CustomerAddController({required this.repository});

  var base64Files = <Map<String, String>>[].obs; // Reactive list
  var isLoading = false.obs;

  void clearFiles() {
    base64Files.clear();
  }

  /// Add Payable
  Future<void> addCustomerPayable({
    required int customerId,
    required String date,
    required int saleId,
    required String paymentAmount,
    required String description,
  }) async {
    try {
      isLoading.value = true;
      final body = {
        "action": "create_pay",
        "date": date,
        "sale_id": saleId,
        "payment_amount": paymentAmount,
        "description": description,
      };

      final response = await repository.postPayable(customerId, body);

      if (response.containsKey("detail")) {
        showWarning( response["detail"]);
      } else {
         showSuccess( "Payable added successfully");
      }
    } catch (e) {
      showError( e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Add Receivable
  Future<void> addCustomerReceivable({
    required int customerId,
    required String date,
    required int saleId,
    required String paymentAmount,
    required String description,
    required List<String>? documents,
  }) async {
    try {
      isLoading.value = true;

      final body = {
        "action": "create_pay",
        "date": date,
        "sale_id": saleId,
        "payment_amount": paymentAmount,
        "description": description,
        "documents": [
          {"file_type": 1, "documents": documents},
        ],
      };

      final response = await repository.postReceivable(customerId, body);

      if (response.containsKey("detail")) {
       showWarning( response["detail"]);
      } else {
         showSuccess("Receivable added successfully");
      }
    } catch (e) {
     showError( e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick Multiple Files
  Future<void> pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null) {
        base64Files.clear();
        for (var file in result.files) {
          if (file.bytes != null) {
            String base64Str = base64Encode(file.bytes!);
            base64Files.add({"fileName": file.name, "base64": base64Str});
          }
        }
      } else {}
    } catch (e) {
     showError( "Failed to pick files: $e");
    }
  }
}
