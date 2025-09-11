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
