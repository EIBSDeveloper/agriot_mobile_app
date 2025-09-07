class HarvestingType {
  final int id;
  final String name;

  HarvestingType({required this.id, required this.name});

  factory HarvestingType.fromJson(Map<String, dynamic> json) => HarvestingType(id: json['id'], name: json['name']);
}
