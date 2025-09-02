import '../../task/view/screens/screen.dart';

class DropdownItem extends NamedItem{
  @override
  final int id;
    @override
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