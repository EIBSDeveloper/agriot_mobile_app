class InventoryPermission {
    final int? list;
    final int? consumption;
    final int? view;

    InventoryPermission({
        this.list,
        this.consumption,
        this.view,
    });

    factory InventoryPermission.fromJson(Map<String, dynamic> json) => InventoryPermission(
        list: json["list"],
        consumption: json["consumption"],
        view: json["view"],
    );

    Map<String, dynamic> toJson() => {
        "list": list,
        "consumption": consumption,
        "view": view,
    };
}

