// Payables History
class PayableHistorymodel {
  final int id;
  final double balance;
  final double paid;
  final double paymentAmount;
  final double toPay;
  final double totalPaid;
  final String paidDate;
  final String? description;
  final int status;
  final String createdAt;

  PayableHistorymodel({
    required this.id,
    required this.balance,
    required this.paid,
    required this.paymentAmount,
    required this.toPay,
    required this.totalPaid,
    required this.paidDate,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory PayableHistorymodel.fromJson(Map<String, dynamic> json) => PayableHistorymodel(
      id: json['id'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      paid: (json['paid'] ?? 0).toDouble(),
      paymentAmount: (json['payment_amount'] ?? 0).toDouble(),
      toPay: (json['to_pay'] ?? 0).toDouble(),
      totalPaid: (json['total_paid'] ?? 0).toDouble(),
      paidDate: json['paid_date'] ?? '',
      description: json['description'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
}

// Receivables History
class ReceivableHistorymodel {
  final int id;
  final double balance;
  final double received;
  final double paymentAmount;
  final double toReceive;
  final double totalReceived;
  final String receivedDate;
  final String? description;
  final int status;
  final String createdAt;

  ReceivableHistorymodel({
    required this.id,
    required this.balance,
    required this.received,
    required this.paymentAmount,
    required this.toReceive,
    required this.totalReceived,
    required this.receivedDate,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory ReceivableHistorymodel.fromJson(Map<String, dynamic> json) => ReceivableHistorymodel(
      id: json['id'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      received: (json['received'] ?? 0).toDouble(),
      paymentAmount: (json['payment_amount'] ?? 0).toDouble(),
      toReceive: (json['to_receive'] ?? 0).toDouble(),
      totalReceived: (json['total_received'] ?? 0).toDouble(),
      receivedDate: json['received_date'] ?? '',
      description: json['description'],
      status: json['status'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
}
