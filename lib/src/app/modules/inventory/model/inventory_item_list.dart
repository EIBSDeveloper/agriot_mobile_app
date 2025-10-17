class InventoryItemList {
    final int id;
    final int availableQuans;
    final String name;
    final String unitType;

    InventoryItemList({
        required this.id,
        required this.availableQuans,
        required this.name,
        required this.unitType,
    });

    InventoryItemList copyWith({
        int? id,
        int? availableQuans,
        String? name,
        String? unitType,
    }) => 
        InventoryItemList(
            id: id ?? this.id,
            availableQuans: availableQuans ?? this.availableQuans,
            name: name ?? this.name,
            unitType: unitType ?? this.unitType,
        );

    factory InventoryItemList.fromJson(Map<String, dynamic> json) => InventoryItemList(
        id: json["id"]??0,
        availableQuans: json["available_quans"]?.round()??0,
        name: json["name"]??'',
        unitType: json["unit_type"]??'',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "available_quans": availableQuans,
        "name": name,
        "unit_type": unitType,
    };
}
