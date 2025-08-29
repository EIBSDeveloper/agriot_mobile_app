// lib/controller/payables_receivables_controller.dart
import 'package:get/get.dart';

import '../../model/payables_receivables_model/payables_receivables_model.dart';
import '../../repository/payables_receivables_repository/payables_receivables_repository.dart';

class PayablesReceivablesController extends GetxController {
  final PayablesReceivablesRepository repository;

  PayablesReceivablesController({required this.repository});

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var data = Rxn<PayablesReceivablesList>();

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await repository.fetchPayablesReceivablesList();
      data.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
