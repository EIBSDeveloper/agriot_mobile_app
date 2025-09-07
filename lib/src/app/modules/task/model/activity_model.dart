import 'package:argiot/src/app/modules/task/model/named_item.dart';

class ActivityModel implements NamedItem {
  @override
  final int id;

  @override
  final String name;

  ActivityModel({required this.id, required this.name});

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      ActivityModel(id: json['id'], name: json['name']);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ActivityModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ActivityModel(id: $id, name: $name)';
}
