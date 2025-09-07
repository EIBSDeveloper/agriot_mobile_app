import 'package:argiot/src/app/modules/expense/model/expense.dart';
import 'package:argiot/src/app/modules/expense/model/purchase.dart';

class ExpenseResponse {
  final bool success;
  final List<Expense> expenses;
  final List<Purchase> purchases;

  ExpenseResponse({
    required this.success,
    required this.expenses,
    required this.purchases,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) => ExpenseResponse(
      success: json['success'],
      expenses: List<Expense>.from(
        json['expenses'].map((x) => Expense.fromJson(x)),
      ),
      purchases: List<Purchase>.from(
        json['purchases'].map((x) => Purchase.fromJson(x)),
      ),
    );
}
