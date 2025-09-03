import '../../task/view/screens/screen.dart';

class AppDropdownItem extends NamedItem{
  @override
  final int id;
    @override
  final String name;
  final String? description;

  AppDropdownItem({
    required this.id,
    required this.name,
    this.description,
  });

  factory AppDropdownItem.fromJson(Map<String, dynamic> json) {
    return AppDropdownItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}