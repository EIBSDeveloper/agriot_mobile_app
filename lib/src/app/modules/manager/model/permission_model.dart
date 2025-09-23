class PermissionItem {
  String name;
  int status;
  Map<String, PermissionItem> children;

  PermissionItem({
    required this.name,
    this.status = 0,
    Map<String, PermissionItem>? children,
  }) : children = children ?? {};

  factory PermissionItem.fromJson(String name, Map<String, dynamic> json) {
    // Check for nested structures: actions, modules, categories
    Map<String, dynamic> nested =
        json['actions'] ?? json['modules'] ?? json['categories'] ?? {};

    return PermissionItem(
      name: name,
      status: json['status'] ?? 0,
      children: nested.map(
        (key, value) => MapEntry(key, PermissionItem.fromJson(key, value)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
      "status": status,
      if (children.isNotEmpty)
        "children": children.map((k, v) => MapEntry(k, v.toJson())),
    };
}
