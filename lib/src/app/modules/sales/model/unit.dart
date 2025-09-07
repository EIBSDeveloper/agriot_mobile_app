import 'package:argiot/src/app/modules/task/model/named_item.dart';


class Unit extends NamedItem {
  @override
  final int id;
  @override
  final String name;

  Unit({required this.id, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) =>
      Unit(id: json['id'] ?? 0, name: json['name'] ?? '');
}
