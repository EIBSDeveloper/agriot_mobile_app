import 'package:argiot/src/payable/model/model_pay_receive/errormodel.dart';
import 'package:argiot/src/payable/model/model_pay_receive/pay_receivemodel.dart';
import 'package:argiot/src/payable/repository/repo_pay_receive/pay_receiverepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CustomerlistController extends GetxController {
  final CustomerlistRepository repository;

  CustomerlistController({required this.repository});

  // Observables
  var customerPayables = <Customerlistmodel>[].obs;
  var customerReceivables = <Customerlistmodel>[].obs;
  var vendorPayables = <Customerlistmodel>[].obs;
  var vendorReceivables = <Customerlistmodel>[].obs;

  var isLoadingCustomerPayables = false.obs;
  var isLoadingCustomerReceivables = false.obs;
  var isLoadingVendorPayables = false.obs;
  var isLoadingVendorReceivables = false.obs;

  // ----------------- Pagination -----------------
  final ScrollController payablesScrollController = ScrollController();
  final ScrollController receivablesScrollController = ScrollController();

  var payablesEndMessage = ''.obs;
  var receivablesEndMessage = ''.obs;

  final RxInt payablesCurrentMax = 5.obs;
  final RxInt receivablesCurrentMax = 5.obs;

  final int pageSize = 5;

  void setupPayablesPagination(int selectedTopToggle) {
    payablesScrollController.addListener(() {
      final items = selectedTopToggle == 0 ? customerPayables : vendorPayables;
      if (payablesScrollController.position.pixels >=
          payablesScrollController.position.maxScrollExtent - 20) {
        if (payablesCurrentMax.value < items.length) {
          payablesCurrentMax.value =
              (payablesCurrentMax.value + pageSize <= items.length)
              ? payablesCurrentMax.value + pageSize
              : items.length;
        } else {
          final errorModel = Errormodel(
            error: "end_reached",
            message: "You have reached the end of the list.",
          );
          payablesEndMessage.value = errorModel.message ?? '';
        }
      }
    });
  }

  void setupReceivablesPagination(int selectedTopToggle) {
    receivablesScrollController.addListener(() {
      final items = selectedTopToggle == 0
          ? customerReceivables
          : vendorReceivables;
      if (receivablesScrollController.position.pixels >=
          receivablesScrollController.position.maxScrollExtent - 20) {
        if (receivablesCurrentMax.value < items.length) {
          receivablesCurrentMax.value =
              (receivablesCurrentMax.value + pageSize <= items.length)
              ? receivablesCurrentMax.value + pageSize
              : items.length;
        } else {
          final errorModel = Errormodel(
            error: "end_reached",
            message: "You have reached the end of the list.",
          );
          receivablesEndMessage.value = errorModel.message ?? '';
        }
      }
    });
  }

  // ----------------- Customer -----------------
  Future<void> fetchCustomerPayables() async {
    try {
      isLoadingCustomerPayables.value = true;
      final data = await repository.fetchCustomerPayableslist();
      customerPayables.value = data;
    } catch (e) {
      print("Error fetching customer payables: $e");
    } finally {
      isLoadingCustomerPayables.value = false;
    }
  }

  Future<void> fetchCustomerReceivables() async {
    try {
      isLoadingCustomerReceivables.value = true;
      final data = await repository.fetchCustomerReceivableslist();
      customerReceivables.value = data;
    } catch (e) {
      print("Error fetching customer receivables: $e");
    } finally {
      isLoadingCustomerReceivables.value = false;
    }
  }

  // ----------------- Vendor -----------------
  Future<void> fetchVendorPayables() async {
    try {
      isLoadingVendorPayables.value = true;
      final data = await repository.fetchVendorReceivableslist();
      vendorPayables.value = data;
    } catch (e) {
      print("Error fetching vendor payables: $e");
    } finally {
      isLoadingVendorPayables.value = false;
    }
  }

  Future<void> fetchVendorReceivables() async {
    try {
      isLoadingVendorReceivables.value = true;
      final data = await repository.fetchVendorReceivableslist();
      vendorReceivables.value = data;
    } catch (e) {
      print("Error fetching vendor receivables: $e");
    } finally {
      isLoadingVendorReceivables.value = false;
    }
  }

  // ----------------- Fetch all at once -----------------
  Future<void> fetchAllData() async {
    await Future.wait([
      fetchCustomerPayables(),
      fetchCustomerReceivables(),
      fetchVendorPayables(),
      fetchVendorReceivables(),
    ]);
  }
}
