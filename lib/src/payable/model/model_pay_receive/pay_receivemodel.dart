class Customerlistmodel {
  final int id;
  final String name;
  final String businessName;
  final bool isCredit;
  final double balance;

  Customerlistmodel({
    required this.id,
    required this.name,
    required this.businessName,
    required this.isCredit,
    required this.balance,
  });

  factory Customerlistmodel.fromJson(Map<String, dynamic> json) => Customerlistmodel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      businessName: json['business_name'] ?? '',
      isCredit: json['is_credit'] ?? false,
      balance: (json['balance'] ?? 0).toDouble(),
    );

  Map<String, dynamic> toJson() => {
      "id": id,
      "name": name,
      "business_name": businessName,
      "is_credit": isCredit,
      "balance": balance,
    };
}
