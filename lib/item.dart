class Item {
  final int id;
  final String quantity;

  Item({required this.id, required this.quantity});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      quantity: json['total_quantity'] ?? json['total_fuel_capacity'] ?? '0',
    );
  }
}

class PurchaseModel {
  final Map<String, Item> items;

  PurchaseModel({required this.items});

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, Item> parsedItems = {};

    json.forEach((key, value) {
      if (json[key]!['id'] != null) {
        parsedItems[key] = Item.fromJson(value);
      }
    });

    return PurchaseModel(items: parsedItems);
  }
}
