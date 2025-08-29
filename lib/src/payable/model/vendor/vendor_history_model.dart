class VendorPayableHistoryModel {
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

  VendorPayableHistoryModel({
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

  factory VendorPayableHistoryModel.fromJson(Map<String, dynamic> json) {
    return VendorPayableHistoryModel(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'balance': balance,
    'paid': paid,
    'payment_amount': paymentAmount,
    'to_pay': toPay,
    'total_paid': totalPaid,
    'paid_date': paidDate,
    'description': description,
    'status': status,
    'created_at': createdAt,
  };
}

class VendorReceivableHistoryModel {
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

  VendorReceivableHistoryModel({
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

  factory VendorReceivableHistoryModel.fromJson(Map<String, dynamic> json) {
    return VendorReceivableHistoryModel(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'balance': balance,
    'received': received,
    'payment_amount': paymentAmount,
    'to_receive': toReceive,
    'total_received': totalReceived,
    'received_date': receivedDate,
    'description': description,
    'status': status,
    'created_at': createdAt,
  };
}
