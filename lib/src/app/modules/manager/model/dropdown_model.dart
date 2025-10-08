// gender_model.dart
class DrapDown {
  final int id;
  final String name;

  DrapDown({required this.id, required this.name});

  factory DrapDown.fromJson(Map<String, dynamic> json) =>
      DrapDown(id: json['id'], name: json['name']);
}

