// models/sales_model.dart

class Rupee {
  final int id;
  final String name;

  Rupee({required this.id, required this.name});

  factory Rupee.fromJson(Map<String, dynamic> json) =>
      Rupee(id: json['id'] ?? 0, name: json['name'] ?? '');
}