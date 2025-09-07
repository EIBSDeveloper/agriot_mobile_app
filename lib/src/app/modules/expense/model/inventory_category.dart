class InventoryCategory {
  final int id;
  final String name;
  final String type;

  InventoryCategory({required this.id, required this.name, required this.type});

  factory InventoryCategory.fromJson(Map<String, dynamic> json) => InventoryCategory(
      id: json['id'],
      name: json['name'],
      type: json['inventory_type']?['name'] ?? '',
    );
}
