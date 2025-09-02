import 'land_detail_model.dart';

class Land {
  final int id;
  final String name;
  // final Village village;
  final double measurementValue;
  final MeasurementUnit measurementUnit;
  final int landCropCount;
  final List<CropCardModel> crops;

  Land({
    required this.id,
    required this.name,
    // required this.village,
    required this.measurementValue,
    required this.measurementUnit,
    required this.landCropCount,
    required this.crops,
  });

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'],
      name: json['name'],
      // village: Village.fromJson(json['village']),
      measurementValue: json['measurement_value'].toDouble(),
      measurementUnit: MeasurementUnit.fromJson(json['measurement_unit']),
      landCropCount: json['land_crop_count'],
      crops: List<CropCardModel>.from(json['crops'].map((x) => CropCardModel.fromJson(x))),
    );
  }
}

class Village {
  final int id;
  final String name;

  Village({required this.id, required this.name});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(id: json['id'], name: json['name']);
  }
}

class MeasurementUnit {
  final int id;
  final String name;

  MeasurementUnit({required this.id, required this.name});

  factory MeasurementUnit.fromJson(Map<String, dynamic> json) {
    return MeasurementUnit(id: json['id'], name: json['name']);
  }
}