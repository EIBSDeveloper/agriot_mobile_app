import 'package:argiot/src/app/modules/task/model/named_item.dart';

class CropModel implements NamedItem {
  @override
  final int id;

  @override
  final String name;

  CropModel({required this.id, required this.name});

  factory CropModel.fromJson(Map<String, dynamic> json) => CropModel(id: json['id'], name: json['name']);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CropModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CropModel(id: $id, name: $name)';
}
