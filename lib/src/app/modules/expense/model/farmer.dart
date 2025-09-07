// ignore_for_file: constant_pattern_never_matches_value_type

class Farmer {
  final int id;
  final String name;

  Farmer({required this.id, required this.name});

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(id: json['id'] ?? 0, name: json['name'] ?? '');
}
