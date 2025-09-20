// class Item {

//   Item({required this.id, required this.quantity});

//   factory Item.fromJson(Map<String, dynamic> json) => Item(
//       id: json['id'],
//       quantity: json['total_quantity'] ?? json['total_fuel_capacity'] ?? '0',
//     );
//   final int id;
//   final String quantity;
// }

// class PurchaseModel {

//   PurchaseModel({required this.items});

//   factory PurchaseModel.fromJson(Map<String, dynamic> json) {
//     final Map<String, Item> parsedItems = {};

//     json.forEach((key, value) {
//       if (json[key]!['id'] != null) {
//         parsedItems[key] = Item.fromJson(value);
//       }
//     });

//     return PurchaseModel(items: parsedItems);
//   }
//   final Map<String, Item> items;
// }
