class FuelConsumptionModel {
  final String dateOfConsumption;
  final int crop;
  final int inventoryType;
  final int inventoryCategory;
  final int inventoryItems;
  final String description;
  final String farmer;
  final double quantityUtilized;
  final List<Document> documents;

  FuelConsumptionModel({
    required this.dateOfConsumption,
    required this.crop,
    required this.inventoryType,
    required this.inventoryCategory,
    required this.inventoryItems,
    required this.description,
    required this.farmer,
    required this.quantityUtilized,
    required this.documents,
  });

  Map<String, dynamic> toJson() {
    return {
      'date_of_consumption': dateOfConsumption,
      'crop': crop,
      'inventory_type': inventoryType,
      'inventory_category': inventoryCategory,
      'inventory_items': inventoryItems,
      'description': description,
      'farmer': farmer,
      'quantity_utilized': quantityUtilized.toString(),
      'documents': documents.map((doc) => doc.toJson()).toList(),
    };
  }
}

class Document {
  final String? newFileType;
  final int? fileType;
  final List<String> documents;

  Document({this.newFileType, this.fileType, required this.documents});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (newFileType != null) {
      map['new_file_type'] = newFileType;
    }
    if (fileType != null) {
      map['file_type'] = fileType;
    }
    map['documents'] = documents;
    return map;
  }
}


class DocumentTypeModel {
  final int id;
  final String name;

  DocumentTypeModel({required this.id, required this.name});

  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}


class InventoryItemModel {
  final int id;
  final String name;
  final String? code;
  final int status;
  final String description;
  final int inventoryType;
  final int inventoryCategory;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.description,
    required this.inventoryType,
    required this.inventoryCategory,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
      status: json['status'] ?? 0,
      description: json['description'] ?? '',
      inventoryType: json['inventory_type'] ?? 0,
      inventoryCategory: json['inventory_category'] ?? 0,
    );
  }
}


class InventoryCategoryModel {
  final int id;
  final String name;
  final int inventoryTypeId;

  InventoryCategoryModel({
    required this.id,
    required this.name,
    required this.inventoryTypeId,
  });

  factory InventoryCategoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      inventoryTypeId: json['inventory_type_id'] ?? 0,
    );
  }
}


class InventoryTypeModel {
  final int id;
  final String name;
  final double totalQuantity;

  InventoryTypeModel({
    required this.id,
    required this.name,
    required this.totalQuantity,
  });

  factory InventoryTypeModel.fromJson(String key, Map<String, dynamic> json) {
    return InventoryTypeModel(
      id: json['id'] ?? 0,
      name: key,
      totalQuantity:
          double.tryParse(json['total_quantity']?.toString() ?? '0') ??
          double.tryParse(json['total_fuel_capacity']?.toString() ?? '0') ??
          0,
    );
  }
}
