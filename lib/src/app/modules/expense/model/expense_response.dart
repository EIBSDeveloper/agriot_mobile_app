
// class ExpenseResponse {
//   final bool success;
//   final List<ExpenseAndSales> expenses;
//   final List<ExpenseAndSales> sales;

//   ExpenseResponse({
//     required this.success,
//     required this.expenses,
//     required this.sales,
//   });

//   factory ExpenseResponse.fromJson(Map<String, dynamic> json) => ExpenseResponse(
//       success: json['success'],
//       expenses: List<ExpenseAndSales>.from(
//         json['expenses'].map((x) => ExpenseAndSales.fromJson(x)),
//       ),
//       sales: List<ExpenseAndSales>.from(
//         json['sales'].map((x) => ExpenseAndSales.fromJson(x)),
//       ),
//     );
// }
