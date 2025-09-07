class PurchaseRecord {
  final int id;
  final String vendorName;
  final double quantity;
  final String quantityUnit;
  final double purchaseAmount;
  final DateTime date;
  final String description;

  PurchaseRecord({
    required this.id,
    required this.vendorName,
    required this.quantity,
    required this.quantityUnit,
    required this.purchaseAmount,
    required this.date,
    required this.description,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) => PurchaseRecord(
      id: json['id'],
      vendorName: json['vendor']?['name'] ?? 'Unknown',
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      quantityUnit: json['quantity_unit'] ?? '',
      purchaseAmount:
          double.tryParse(json['purchase_amount']?.toString() ?? '0') ?? 0,
      date: DateTime.parse(json['created_at']),
      description: json['description'] ?? '',
    );
}
