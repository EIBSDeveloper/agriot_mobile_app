class ModulePermission {
    final int? list;
    final int? add;
    final int? edit;
    final int? view;
    final int? delete;
    final int? schedule;
    final int? location;

    ModulePermission({
        this.list,
        this.add,
        this.edit,
        this.view,
        this.delete,
        this.schedule,
        this.location,
    });

    factory ModulePermission.fromJson(Map<String, dynamic> json) => ModulePermission(
        list: json["list"],
        add: json["add"],
        edit: json["edit"],
        view: json["view"],
        delete: json["delete"],
        schedule: json["schedule"],
        location: json["location"],
    );

    Map<String, dynamic> toJson() => {
        "list": list,
        "add": add,
        "edit": edit,
        "view": view,
        "delete": delete,
        "schedule": schedule,
        "location": location,
    };
}
