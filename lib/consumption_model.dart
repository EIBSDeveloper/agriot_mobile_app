class FuelConsumptionModel {
  // final List<Document> documents;

  FuelConsumptionModel({
    required this.dateOfConsumption,
    required this.crop,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.inventoryItems,
    required this.description,
    required this.farmer,
    required this.quantityUtilized,
    // required this.documents,
  });
  final String dateOfConsumption;
  final int crop;
  final int inventoryType;
  final int inventoryCategory;
  final int inventoryItems;
  final String description;
  final String farmer;
  final double quantityUtilized;

  Map<String, dynamic> toJson() => {
    'date_of_consumption': dateOfConsumption,
    'crop': crop,
    'inventory_type': inventoryType,
    'inventory_category': inventoryCategory,
    'inventory_items': inventoryItems,
    'description': description,
    'farmer': farmer,
    'quantity_utilized': quantityUtilized.toString(),
    // 'documents': documents.map((doc) => doc.toJson()).toList(),
  };
}

class DocumentTypeModel {
  DocumentTypeModel({required this.id, required this.name});

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) =>
      DocumentTypeModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  final int id;
  final String name;
}

class InventoryItemModel {
  InventoryItemModel({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.description,
    required this.inventoryType,
    required this.inventoryCategory,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) =>
      InventoryItemModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        code: json['code'],
        status: json['status'] ?? 0,
        description: json['description'] ?? '',
        inventoryType: json['inventory_type'] ?? 0,
        inventoryCategory: json['inventory_category'] ?? 0,
      );
  final int id;
  final String name;
  final String? code;
  final int status;
  final String description;
  final int inventoryType;
  final int inventoryCategory;
}

class InventoryCategoryModel {
  InventoryCategoryModel({
    required this.id,
    required this.name,
    required this.inventoryTypeId,
  });

  factory InventoryCategoryModel.fromJson(Map<String, dynamic> json) =>
      InventoryCategoryModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        inventoryTypeId: json['inventory_type_id'] ?? 0,
      );
  final int id;
  final String name;
  final int inventoryTypeId;
}

class InventoryTypeModel {
  InventoryTypeModel({
    required this.id,
    required this.name,
    required this.totalQuantity,
  });

  factory InventoryTypeModel.fromJson(String key, Map<String, dynamic> json) =>
      InventoryTypeModel(
        id: json['id'] ?? 0,
        name: key,
        totalQuantity:
            double.tryParse(json['total_quantity']?.toString() ?? '0') ??
            double.tryParse(json['total_fuel_capacity']?.toString() ?? '0') ??
            0,
      );
  final int id;
  final String name;
  final double totalQuantity;
}
