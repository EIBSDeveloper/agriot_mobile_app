
import 'package:get/get.dart';

import '../controller/payables_receivables_controller/payables_receivables_controller.dart';
import '../repository/payables_receivables_repository/payables_receivables_repository.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
   

    Get.lazyPut<PayablesReceivablesController>(
      () => PayablesReceivablesController(
        repository: PayablesReceivablesRepository(),
      ),
      fenix: true,
    );
  }
}
