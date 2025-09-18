import 'vendor.dart';

class PurchaseItem {
  final int id;
  final DateTime dateOfConsumption;
  final int purchaseAmount;
  final Vendor? vendor;
  final int? quantity;
  final String? unitType;

  PurchaseItem({
    required this.id,
    required this.dateOfConsumption,
    required this.purchaseAmount,
    this.vendor,
    this.quantity,
    this.unitType,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) => PurchaseItem(
    id: json["id"],
    dateOfConsumption: json["date_of_consumption"] == null
        ? DateTime.now()
        : DateTime.parse(json["date_of_consumption"]),
    purchaseAmount: json["purchase_amount"],
    vendor: json["vendor"] == null ? null : Vendor.fromJson(json["vendor"]),
    quantity: json["quantity"],
    unitType: json["unit_type"],
  );
}
