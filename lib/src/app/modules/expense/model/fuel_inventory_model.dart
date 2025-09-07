import 'package:argiot/src/app/modules/expense/fuel.dart/test.dart';
import 'package:argiot/src/app/modules/expense/model/inventory_type.dart';

import 'inventory_category.dart';
import 'inventory_item.dart';

class FuelInventoryModel {
  final int fuelId;
  final double quantity;
  final double purchaseAmount;
  final String description;
  final String date;
  final InventoryItem inventoryItem;
  final InventoryType inventoryType;
  final InventoryCategory inventoryCategory;
  final Vendor vendor;
  final List<DocumentCategory> documents;

  FuelInventoryModel({
    required this.fuelId,
    required this.quantity,
    required this.purchaseAmount,
    required this.description,
    required this.date,
    required this.inventoryItem,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.vendor,
    required this.documents,
  });

  factory FuelInventoryModel.fromJson(Map<String, dynamic> json) => FuelInventoryModel(
      fuelId: json['fuel_id'] ?? 0,
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      purchaseAmount: (json['purchase_amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      inventoryItem: InventoryItem.fromJson(json['inventory_item'] ?? {}),
      inventoryType: InventoryType.fromJson(json['inventory_type'] ?? {}),
      inventoryCategory: InventoryCategory.fromJson(
        json['inventory_category'] ?? {},
      ),
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((doc) => DocumentCategory.fromJson(doc))
          .toList(),
    );
}
