import '../../task/view/screens/screen.dart';

class AppDropdownItem extends NamedItem {
  @override
  final int id;
  @override
  final String name;
  final int? doctype;
  final String? description;

  AppDropdownItem({
    required this.id,
    required this.name,
    this.doctype,
    this.description,
  });

  factory AppDropdownItem.fromJson(Map<String, dynamic> json) {
    return AppDropdownItem(
      id: json['id'],
      doctype: json['doctype'],
      name: json['name'],
      description: json['description'],
    );
  }
}
