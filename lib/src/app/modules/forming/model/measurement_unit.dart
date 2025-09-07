class MeasurementUnit {
  final int id;
  final String name;

  MeasurementUnit({required this.id, required this.name});

  factory MeasurementUnit.fromJson(Map<String, dynamic> json) => MeasurementUnit(id: json['id'], name: json['name']);
}
