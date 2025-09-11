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
