import 'package:argiot/common.dart';
import 'package:argiot/src/app/modules/expense/model/farmer.dart';

class Purchase {
  final int id;
  final Farmer farmer;
  final String dateOfConsumption;
  final Vendor vendor;
  final InventoryItem inventorytype;
  final InventoryItem inventoryItems;
  final String quantity;
  final String purchaseAmount;
  final String? availableQuans;
  final String type;

  Purchase({
    required this.id,
    required this.farmer,
    required this.dateOfConsumption,
    required this.vendor,
    required this.inventorytype,
    required this.inventoryItems,
    required this.quantity,
    required this.purchaseAmount,
    this.availableQuans,
    required this.type,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
      id: json['id'],
      farmer: Farmer.fromJson(json['farmer']),
      dateOfConsumption: json['date_of_consumption'],
      vendor: Vendor.fromJson(json['vendor']),
      inventorytype: InventoryItem.fromJson(json['inventory_type']),
      inventoryItems: InventoryItem.fromJson(json['inventory_items']),
      quantity: json['quantity']??"0",
      purchaseAmount: json['purchase_amount'],
      availableQuans: json['available_quans']?.toString(),
      type: json['type'],
    );
}
