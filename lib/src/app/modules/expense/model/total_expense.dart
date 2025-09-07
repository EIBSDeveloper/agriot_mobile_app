class TotalExpense {
  final bool success;
  final double expenseAmount;

  TotalExpense({required this.success, required this.expenseAmount});

  factory TotalExpense.fromJson(Map<String, dynamic> json) => TotalExpense(
      success: json['success'],
      expenseAmount: json['expenseamount'].toDouble(),
    );
}
