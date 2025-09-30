class VendorHistoryModel {
  final int id;
  final double balance;
  final double paid;
  final double paymentAmount;
  final double toPay;
  final double totalPaid;
  final String paidDate;
  final String description;
  final int status;

  VendorHistoryModel({
    required this.id,
    required this.balance,
    required this.paid,
    required this.paymentAmount,
    required this.toPay,
    required this.totalPaid,
    required this.paidDate,
    required this.description,
    required this.status,
  });

  factory VendorHistoryModel.fromJson(Map<String, dynamic> json) => VendorHistoryModel(
      id: json['id'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      paid: (json['paid'] ?? 0).toDouble(),
      paymentAmount: (json['payment_amount'] ?? 0).toDouble(),
      toPay: (json['to_pay'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      paidDate: json['paid_date'] ?? '',
      description: json['description'] ?? '-',
      status: json['status'] ?? 0,
    );
}
