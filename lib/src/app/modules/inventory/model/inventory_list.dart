import 'package:argiot/src/app/modules/inventory/model/inventory_item_list.dart';

class InventoryList {
  final int id;
  final String name;
  final List<InventoryItemList>? items;
  final int count;

  InventoryList({required this.id, required this.name, this.items, required this.count});

  InventoryList copyWith({
    int? id,
    String? name,
    List<InventoryItemList>? items,
    int? count,
  }) => InventoryList(
    id: id ?? this.id,
    name: name ?? this.name,
    items: items ?? this.items,
    count: count ?? this.count,
  );

  factory InventoryList.fromJson(Map<String, dynamic> json) => InventoryList(
    id: json["id"]??0,
    name: json["name"]??'',
    items: json["items"] == null
        ? []
        : List<InventoryItemList>.from(
            json["items"]!.map((x) => InventoryItemList.fromJson(x)),
          ),
    count: json["count"]??0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "items": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
    "count": count,
  };
}
