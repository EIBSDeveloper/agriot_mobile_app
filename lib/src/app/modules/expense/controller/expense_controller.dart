import 'package:argiot/src/app/modules/expense/model/expense.dart';
import 'package:argiot/src/app/modules/expense/model/chart.dart';
import 'package:argiot/src/app/modules/expense/repostroy/expense_repository.dart';
import 'package:argiot/src/app/modules/expense/model/expense_summary.dart';
import 'package:argiot/src/app/modules/task/model/crop_model.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../model/customer.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _repository = Get.find<ExpenseRepository>();
  final farmerId = 1; // This should come from auth or previous screen

  // For overview screen
  final totalExpense = 0.0.obs;
  final selectedPeriod = 'month'.obs;
  final expenseSummary = <ExpenseSummary>[].obs;

  // New grouped records
  final allGroupedRecords = <GroupedExpenseRecord>[].obs;
  final expenseGroupedRecords = <GroupedExpenseRecord>[].obs;
  final salesGroupedRecords = <GroupedExpenseRecord>[].obs;


  final selectedTab = 0.obs; 

  // For add expense screen
  final isPurchase = false.obs;
  final selectedCrop = CropModel(id: 0, name: '').obs;
  final selectedDate = DateTime.now().obs;
  final RxInt amount = 0.obs;
  final RxInt paidamonut = 0.obs;
  final description = ''.obs;
  final RxList<CropModel> crop = <CropModel>[].obs;

  final isLoading = false.obs;
  var selectedVendor = Rx<int?>(null);
  var selectedCustomer = Rx<int?>(null);
  var cardexpenses = <Chart>[].obs;
  var vendorList = <Customer>[].obs;
  var customerList = <Customer>[].obs;
  var cardtotalExpenses = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenseData();
    fetchVendorList();
    fetchCustomerList();
  }

  Future<void> loadExpenseData() async {
    try {
      isLoading(true);
      await _loadGroupedData();
      final total = await _repository.getTotalExpense(selectedPeriod.value);
      totalExpense(total.expenseAmount);
      await fetchCrop();

      // Load data based on selected tab

      cardexpenses.clear();
      final summary = await _repository.getExpenseSummary(selectedPeriod.value);
      cardexpenses.addAll(summary);
      cardtotalExpenses.value = summary.fold(
        0,
        (sum, item) => sum + item.totalAmount,
      );
    } catch (e) {
      showError('Error loading data: $e');
    } finally {
      isLoading(false);
    }
  }
  Future<void> fetchCustomerList() async {
    try {
      final response = await _repository.getCustomerList();
      customerList.assignAll(response);
    } catch (e) {
      showError('Failed to fetch customers: $e');
    }
  }
  Future<void> _loadGroupedData() async {
    try {
      switch (selectedTab.value) {
        case 0: // All
          final data = await _repository.getBothExpensesAndSales(
            selectedPeriod.value,
          );
          allGroupedRecords.assignAll(data);
          break;
        case 1: // Expenses
          final data = await _repository.getExpensesOnly(selectedPeriod.value);
          expenseGroupedRecords.assignAll(data);
          break;
        case 2: // Sales
          final data = await _repository.getSalesOnly(selectedPeriod.value);
          salesGroupedRecords.assignAll(data);
          break;
      }
    } catch (e) {
      showError('Error loading grouped data: $e');
    }
  }

  Future<void> fetchCrop() async {
    final cropList = await _repository.getCropList();
    crop.assignAll(cropList);

    if (cropList.isNotEmpty) {
      selectedCrop.value = cropList.first;
    }
  }

  Future<void> fetchVendorList() async {
    try {
      final response = await _repository.getVendorList();
      vendorList.assignAll(response);
    } catch (e) {
      showError('Failed to fetch customers: $e');
    }
  }

  Future<bool> submitExpense() async {
    if (selectedCrop.value.id == 0) {
      showError('Please select a crop');
      return false;
    }

    if (amount.value <= 0) {
      showError('Please enter a valid amount');
      return false;
    }

    try {
      isLoading(true);
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);

      final success = await _repository.addExpense(
        createdDay: formattedDate,
        myCrop: selectedCrop.value.id,
        amount: amount.value,
        vendor: selectedVendor.value,
        paidamonut: paidamonut.value,
        description: description.value,
      );

      if (success['success']) {
        Get.back();
        loadExpenseData();
        showSuccess('Expense added successfully');
        return true;
      } else {
        showError('${success['message']}');
        return false;
      }
    } catch (e) {
      showError('Error');
      return false;
    } finally {
      isLoading(false);
    }
  }

  void changePeriod(String? period) {
    if (period != null) {
      selectedPeriod(period);
      Get.back();
      loadExpenseData();
    }
  }

  void changeTab(int index) {
    selectedTab(index);
    _loadGroupedData(); // Load specific data when tab changes
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate(picked);
    }
  }
}
