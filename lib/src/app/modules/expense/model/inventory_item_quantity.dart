class InventoryItemQuantity {
  final int id;
  final int availableQuans;
  final String name;
  final String unitType;

  InventoryItemQuantity({
    required this.id,
    required this.availableQuans,
    required this.name,
    required this.unitType,
  });

  factory InventoryItemQuantity.fromJson(Map<String, dynamic> json) =>
      InventoryItemQuantity(
        id: json["id"],
        availableQuans: (json["available_quans"] != null)
            ? (double.tryParse(json["available_quans"].toString()) ?? 0.0)
                  .round()
            : 0,
        name: json["name"],
        unitType: json["unit_type"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "available_quans": availableQuans,
    "name": name,
    "unit_type": unitType,
  };
}
