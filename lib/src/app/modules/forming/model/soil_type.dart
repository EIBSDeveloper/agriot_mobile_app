class SoilType {
  final int? id;
  final String? name;

  SoilType({required this.id, required this.name});

  factory SoilType.fromJson(Map<String, dynamic> json) => SoilType(id: json['id'], name: json['name']);
}
