

// import 'package:argiot/src/app/modules/expense/model/expense.dart';
// import 'package:argiot/src/app/modules/expense/model/chart.dart';
// import 'package:argiot/src/app/modules/expense/repostroy/expense_repository.dart';
// import 'package:argiot/src/app/modules/expense/model/expense_summary.dart';
// import 'package:argiot/src/app/modules/expense/model/expense_type.dart';
// import 'package:argiot/src/app/modules/expense/model/file_type.dart';
// import 'package:argiot/src/app/modules/expense/model/purchase.dart';
// import 'package:argiot/src/app/modules/task/model/crop_model.dart';
// import 'package:argiot/src/app/service/utils/pop_messages.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';


// class ExpenseAddController extends GetxController {
//   final ExpenseRepository _repository = Get.find<ExpenseRepository>();
//   final farmerId = 1; // This should come from auth or previous screen

//   // For overview screen
//   final totalExpense = 0.0.obs;
//   final selectedPeriod = '30days'.obs;
//   final expenseSummary = <ExpenseSummary>[].obs;
//   final expenses = <Expense>[].obs;
//   final purchases = <Purchase>[].obs;
//   final selectedTab = 0.obs; // 0: All, 1: Expenses, 2: Purchases

//   // For add expense screen
//   final isPurchase = false.obs;
//   final selectedCrop = CropModel(id: 0, name: '').obs;
//   final selectedDate = DateTime.now().obs;
//   final amount = 0.0.obs;
//   final description = ''.obs;
//   final RxList<CropModel> crop = <CropModel>[].obs;

//   final fileTypes = <FileType>[].obs;
//   final isLoading = false.obs;

//   var cardexpenses = <Chart>[].obs;

//   var cardtotalExpenses = 0.0.obs;

//   // ✅ Color list moved here
//   final List<Color> colorList = [
//     const Color(0xFF558B2F), // Wages - green
//     const Color(0xFF8D6E63), // Transportation - brown
//     const Color(0xFFFFCA28), // Petrol - yellow
//     const Color(0xFF9CCC65), // Tools - light green
//     const Color(0xFFEF6C00), // Others - orange
//   ];
//   @override
//   void onInit() {
//     super.onInit();
//     loadExpenseData();
//     loadFileTypes();
//   }

//   Future<void> loadExpenseData() async {
//     try {
//       isLoading(true);
//       final total = await _repository.getTotalExpense(selectedPeriod.value);
//       totalExpense(total.expenseAmount);
//       await fetchCrop();
//       // final summary = await _repository.getExpenseSummary(selectedPeriod.value);
//       // expenseSummary.assignAll(summary);
    

//       final response = await _repository.getExpenses(selectedPeriod.value);
//       expenses.assignAll(response.expenses);
//       purchases.assignAll(response.purchases);

//         cardexpenses.clear();
//       final summary = await _repository.getExpenseSummary(selectedPeriod.value);

//       cardexpenses.addAll(summary);
//       cardtotalExpenses.value = summary.fold(
//         0,
//         (sum, item) => sum + item.totalAmount,
//       );
//     } catch (e) {
//      showError('Error', );
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<void> fetchCrop() async {
//        final cropList = await _repository.getCropList();
//     crop.assignAll(cropList);
    
//     if (cropList.isNotEmpty) {
//       selectedCrop.value = cropList.first;
//     }
//   }

//   Future<void> loadFileTypes() async {
//     try {
//       final types = await _repository.getFileTypes();
//       fileTypes.assignAll(types);
//     } catch (e) {
//       showError( 'Failed to load file types');
//     }
//   }

//   Future<bool> submitExpense() async {
//     if (selectedCrop.value.id == 0) {
//       showError( 'Please select a crop');
//       return false;
//     }
//     // if (selectedExpenseType.value.id == 0) {
//     //   showError('Please select an expense type');
//     //   return false;
//     // }
//     if (amount.value <= 0) {
//       showError( 'Please enter a valid amount');
//       return false;
//     }

//     try {
//       isLoading(true);
//       final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
//       final success = await _repository.addExpense(
//         selectedCrop.value.id,
//         amount.value,
   
//         formattedDate,
//         description.value,
//       );

//       if (success['success']) {
//         Get.back();
//         loadExpenseData();
//         showSuccess( 'Expense added successfully');
//         return true;
//       } else {
//         showError('${success['message']}');
//         return false;
//       }
//     } catch (e) {
//       showError('Error');
//       return false;
//     } finally {
//       isLoading(false);
//     }
//   }

//   void changePeriod(String? period) {
//     if (period != null) {
//       selectedPeriod(period);
//       loadExpenseData();
//     }
//   }

//   void changeTab(int index) {
//     selectedTab(index);
//   }

//   Future<void> selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate.value,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != selectedDate.value) {
//       selectedDate(picked);
//     }
//   }
// }
