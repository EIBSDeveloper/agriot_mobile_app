class DropdownItem {
  final int id;
  final String name;
  final String? description;

  DropdownItem({
    required this.id,
    required this.name,
    this.description,
  });

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    return DropdownItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}