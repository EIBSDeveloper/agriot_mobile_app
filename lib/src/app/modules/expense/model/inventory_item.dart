

class InventoryItem {

  InventoryItem({
    required this.id,
    required this.name,
    this.code,
    this.description,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
    );
  final int id;
  final String name;
  final String? code;
  final String? description;
}
