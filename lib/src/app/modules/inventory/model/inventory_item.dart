
class InventoryType {
    int id;
    String name;
    String unitType;
    int? quantity;

    InventoryType({
        required this.id,
        required this.name,
        required this.unitType,
        this.quantity,
    });

    factory InventoryType.fromJson(Map<String, dynamic> json) => InventoryType(
        id: json["id"],
        name: json["name"],
        unitType: json["unit_type"],
        quantity: json["quantity"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "unit_type": unitType,
        "quantity": quantity,
    };
}
