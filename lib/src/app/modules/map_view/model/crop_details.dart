import 'package:argiot/src/app/modules/map_view/model/crop_task.dart';

class CropDetails {
  final int id;
  final String crop;
  final String type;
  final String soilType;
  final DateTime plantationDate;
  final String harvestingType;
  final double measurementValue;
  final String measurementUnit;
  final double expense;
  final double sales;
  final List<CropTask> tasks;

  CropDetails({
    required this.id,
    required this.crop,
    required this.type,
    required this.soilType,
    required this.plantationDate,
    required this.harvestingType,
    required this.measurementValue,
    required this.measurementUnit,
    required this.expense,
    required this.sales,
    required this.tasks,
  });

  factory CropDetails.fromJson(Map<String, dynamic> json) => CropDetails(
    id: json['id'] ?? 0,
    crop: json['crop'] ?? '',
    type: json['type'] ?? '',
    soilType: json['soil_type'] ?? '',
    plantationDate: DateTime.parse(json['plantation_date'] ?? '2025-01-01'),
    harvestingType: json['harvesting_type'] ?? '',
    measurementValue: (json['measurement_value'] ?? 0).toDouble(),
    measurementUnit: json['measurement_unit'] ?? '',
    expense: (json['expense'] ?? 0).toDouble(),
    sales: (json['sales'] ?? 0).toDouble(),
    tasks: (json['task'] as List<dynamic>? ?? [])
        .map((taskJson) => CropTask.fromJson(taskJson))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'crop': crop,
    'type': type,
    'soil_type': soilType,
    'plantation_date': plantationDate.toIso8601String().split('T')[0],
    'harvesting_type': harvestingType,
    'measurement_value': measurementValue,
    'measurement_unit': measurementUnit,
    'expense': expense,
    'sales': sales,
    'task': tasks.map((task) => task.toJson()).toList(),
  };
}
