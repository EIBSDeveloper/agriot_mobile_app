class CropLand {
  final int id;
  final String name;
  final double measurementValue;
  final String measurementUnit;

  CropLand({
    required this.id,
    required this.name,
    required this.measurementValue,
    required this.measurementUnit,
  });

  factory CropLand.fromJson(Map<String, dynamic> json) => CropLand(
      id: json['id'],
      name: json['name'],
      measurementValue: json['measurement_value']?.toDouble() ?? 0.0,
      measurementUnit: json['measurement_unit'],
    );
}
