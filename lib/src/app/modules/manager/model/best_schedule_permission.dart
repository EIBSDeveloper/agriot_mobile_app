class BestSchedulePermission {
    final int? list;
    final int? view;

    BestSchedulePermission({
        this.list,
        this.view,
    });

    factory BestSchedulePermission.fromJson(Map<String, dynamic> json) => BestSchedulePermission(
        list: json["list"],
        view: json["view"],
    );

    Map<String, dynamic> toJson() => {
        "list": list,
        "view": view,
    };
}
