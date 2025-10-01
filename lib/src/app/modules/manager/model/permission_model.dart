class PermissionItem {
  String name;
  int status;
  Map<String, PermissionItem> children;

  PermissionItem({
    required this.name,
    this.status = 0,
    this.children = const {},
  });

  // From your previous rawPermissions JSON
  factory PermissionItem.fromJson(String name, Map<String, dynamic> json) {
    Map<String, PermissionItem> childItems = {};
    if (json.containsKey('modules')) {
      json['modules'].forEach((k, v) {
        childItems[k] = PermissionItem.fromJson(k, v);
      });
    }
    if (json.containsKey('actions')) {
      json['actions'].forEach((k, v) {
        childItems[k] = PermissionItem.fromJson(k, v);
      });
    }
    return PermissionItem(
      name: name,
      status: json['status'] ?? 0,
      children: childItems,
    );
  }

  // From API response
  factory PermissionItem.fromApi(String name, dynamic json) {
    Map<String, PermissionItem> childItems = {};

    if (json is Map<String, dynamic>) {
      json.forEach((k, v) {
        childItems[k] = PermissionItem.fromApi(k, v);
      });
    }

    return PermissionItem(
      name: name,
      status: (json is int) ? json : 0,
      children: childItems,
    );
  }
}
