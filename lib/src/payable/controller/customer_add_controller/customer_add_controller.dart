import 'package:get/get.dart';

import '../../../app/modules/document/document.dart';
import '../../../app/service/utils/enums.dart';
import '../../repository/customer_add_repository/customer_add_repository.dart';

class CustomerAddController extends GetxController {
  final CustomerAddRepository repository;

  CustomerAddController({required this.repository});

  var base64Files = <Map<String, String>>[].obs; // Reactive list
  var isLoading = false.obs;

  void clearFiles() {
    base64Files.clear();
    documentItems.clear();
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
        "documents": documentItems.map((e) {
          var json = e.toJson();
          json['document'] = json['documents'][0];
          json['documents'] = [];
          return json;
        }).toList(),
      };

      final response = await repository.postPayable(customerId, body);

      if (response.containsKey("detail")) {
        Get.snackbar("Info", response["detail"]);
      } else {
        Get.snackbar("Success", "Payable added successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
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
  }) async {
    try {
      isLoading.value = true;
      print(documentItems.map((e) => e.toJson().toString()));
      final body = {
        "action": "create_pay",
        "date": date,
        "sale_id": saleId,
        "payment_amount": paymentAmount,
        "description": description,
        "documents": documentItems.map((e) => e.toJson()).toList(),
      };

      final response = await repository.postReceivable(customerId, body);

      if (response.containsKey("detail")) {
        Get.snackbar("Info", response["detail"]);
      } else {
        Get.snackbar("Success", "Receivable added successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  final RxList<AddDocumentModel> documentItems = <AddDocumentModel>[].obs;

  void addDocumentItem() {
    Get.to(
      const AddDocumentView(),
      binding: DocumentBinding(),
      arguments: {"type": DocTypes.payouts},
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
