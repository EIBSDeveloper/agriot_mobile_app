
import 'package:get/get.dart';

import '../../model/customer_history/customer_sales_history.dart';
import '../../repository/customer_history_repository/customer_history_repository.dart';

class CustomerSalesHistoryController extends GetxController {
  final CustomerSalesHistoryRepository repository;

  CustomerSalesHistoryController({required this.repository});

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var payablesHistory = <PayableHistorymodel>[].obs;
  var receivablesHistory = <ReceivableHistorymodel>[].obs;

  var selectedPayable = Rxn<PayableHistorymodel>();
  var selectedReceivable = Rxn<ReceivableHistorymodel>();

  // Load Payables History
  Future<void> loadPayablesHistory({
   
    required int customerId,
    required int saleId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      payablesHistory.value = await repository.fetchPayablesHistory(
        
        customerId: customerId,
        saleId: saleId,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load Receivables History
  Future<void> loadReceivablesHistory({
    
    required int customerId,
    required int saleId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      receivablesHistory.value = await repository.fetchReceivablesHistory(
        
        customerId: customerId,
        saleId: saleId,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load Payable Detail
  Future<void> loadPayableDetail({
   
    required int customerId,
    required int saleId,
    required int outstandingId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedPayable.value = await repository.fetchPayableDetail(
      
        customerId: customerId,
        saleId: saleId,
        outstandingId: outstandingId,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load Receivable Detail
  Future<void> loadReceivableDetail({
   
    required int customerId,
    required int saleId,
    required int outstandingId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedReceivable.value = await repository.fetchReceivableDetail(
       
        customerId: customerId,
        saleId: saleId,
        outstandingId: outstandingId,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
