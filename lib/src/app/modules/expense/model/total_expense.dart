class TotalExpense {
  final bool success;
  final double expenseAmount;
  final double salesAmount;

  TotalExpense({required this.success, required this.expenseAmount,required this.salesAmount});

  factory TotalExpense.fromJson(Map<String, dynamic> json) => TotalExpense(
      success: json['success'],
      expenseAmount: json['expenseamount'].toDouble(),
      salesAmount: json['salesamount'].toDouble(),
    );
}
