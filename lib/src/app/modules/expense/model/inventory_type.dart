class InventoryType {
  final int id;
  final String name;

  InventoryType({required this.id, required this.name});

  factory InventoryType.fromJson(Map<String, dynamic> json) => InventoryType(id: json['id'] ?? 0, name: json['name'] ?? '');
}
