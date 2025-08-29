// lib/controllers/customer_sales_controller.dart
import 'package:get/get.dart';

import '../../model/customer/customer_sales_model.dart';
import '../../model/customer_history/customer_sales_history.dart';
import '../../repository/customer_repository/customer_sales_repository.dart';

class CustomerSalesController extends GetxController {
  final CustomerSalesRepository repository;
  CustomerSalesController({required this.repository});

  var isLoading = false.obs;
  var payables = <CustomerPayable>[].obs;
  var receivables = <CustomerReceivable>[].obs;
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
      // errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Load Receivables History
  Future<void> loadReceivablesHistory({
  
    required int customerId,
    required int? saleId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (saleId != null) {
        receivablesHistory.value = await repository.fetchReceivablesHistory(
         
          customerId: customerId,
          saleId: saleId,
        );
      }
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

      final detail = await repository.fetchReceivableDetail(
      
        customerId: customerId,
        saleId: saleId,
        outstandingId: outstandingId,
      );

      selectedReceivable.value = detail;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPayables( int customerId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      payables.value = await repository.fetchCustomerPayables(
      
        customerId,
      );
      loadPayablesHistory(
        customerId: customerId,
        saleId: payables[0].sales[0].salesId,
      );
    } catch (e) {
      // errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReceivables(int customerId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      receivables.value = await repository.fetchCustomerReceivables(
        
        customerId,
      );
      if (receivables.isNotEmpty) {
        loadReceivablesHistory(
          
          customerId: customerId,
          saleId: receivables[0].sales[0].salesId,
        );
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
