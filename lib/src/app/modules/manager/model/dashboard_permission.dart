class DashboardPermission {
    final int? view;

    DashboardPermission({
        this.view,
    });

    factory DashboardPermission.fromJson(Map<String, dynamic> json) => DashboardPermission(
        view: json["view"],
    );

    Map<String, dynamic> toJson() => {
        "view": view,
    };
}
