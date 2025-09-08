import 'package:get/get.dart';

import '../../../app/service/utils/enums.dart';
import '../../model/customer_history/customer_sales_history.dart';
import '../../model/customer_vendor_model/customer_vendor_model.dart';
import '../../repository/customer_vendor_repository/customer_vendor_repository.dart';

class CustomerVendorController extends GetxController {
  final CustomerVendorRepository repository;

  CustomerVendorController({required this.repository});

  /// Loading indicator
  var isLoading = false.obs;

  /// Vendor and Customer Receivables/Payables
  var vendorReceivables = <VendorReceivable>[].obs;
  var customerReceivables = <CustomerReceivable>[].obs;

  /// Error message
  var error = ''.obs;

  /// Load Receivables (Vendor side)
  Future<void> loadReceivables(int userId, DetailsType? detailsType) async {
    try {
      isLoading.value = true;
      error.value = '';
      final VendorCustomerResponse result;
      if (DetailsType.receivables == detailsType) {
        result = await repository.fetchReceivables(userId);
      } else {
        result = await repository.fetchPayables(userId);
      }
      // assign vendor and customer data
      vendorReceivables.assignAll(result.data.vendorReceivables);
      customerReceivables.assignAll(result.data.customerReceivables);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Full receivable history list
  var historyList = <ReceivableHistorymodel>[].obs;

  /// Selected single history
  var selectedHistory = Rxn<ReceivableHistorymodel>();

  /// Load full receivable history
  Future<void> loadReceivableHistory(
    int farmerId,
    int customerId,
    int saleId,
  ) async {
    try {
      isLoading.value = true;
      final data = await repository.fetchReceivableHistory(
        farmerId,
        customerId,
        saleId,
      );
      historyList.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load single receivable history record
  Future<void> loadSingleReceivableHistory(
    int farmerId,
    int customerId,
    int saleId,
    int outstandingId,
  ) async {
    try {
      isLoading.value = true;
      final data = await repository.fetchReceivableSingleHistory(
        farmerId,
        customerId,
        saleId,
        outstandingId,
      );
      selectedHistory.value = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Full payable history list
  var historypayableList = <PayableHistorymodel>[].obs;

  /// Selected single payable history
  var selectedpayableHistory = Rxn<PayableHistorymodel>();

  /// Load full payable history
  Future<void> loadpayableHistory(
    int farmerId,
    int customerId,
    int saleId,
  ) async {
    try {
      isLoading.value = true;
      final data = await repository.fetchpayablehistory(
        farmerId,
        customerId,
        saleId,
      );
      historypayableList.assignAll(data);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load single payable history record
  Future<void> loadSinglepayableHistory(
    int farmerId,
    int customerId,
    int saleId,
    int outstandingId,
  ) async {
    try {
      isLoading.value = true;
      final data = await repository.fetchpayablesinglehistory(
        farmerId,
        customerId,
        saleId,
        outstandingId,
      );
      selectedpayableHistory.value = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
