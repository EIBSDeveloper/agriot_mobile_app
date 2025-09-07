import 'package:argiot/src/app/modules/forming/model/crop.dart';
import 'package:argiot/src/app/modules/forming/model/cropinfo.dart';
import 'package:argiot/src/app/modules/forming/model/harvesting_type.dart';
import 'package:argiot/src/app/modules/forming/model/measurement_unit.dart';

class CropDetail {
  final int id;
  final Crop cropType;
  final Cropinfo crop;
  final HarvestingType harvestingType;
  final String plantationDate;
  final double measurementValue;
  final MeasurementUnit measurementUnit;
  final String imageUrl;
  final String description;
  final List<List<double>> geoMarks;

  CropDetail({
    required this.id,
    required this.cropType,
    required this.crop,
    required this.harvestingType,
    required this.plantationDate,
    required this.measurementValue,
    required this.measurementUnit,
    required this.imageUrl,
    required this.description,
    required this.geoMarks,
  });

  factory CropDetail.fromJson(Map<String, dynamic> json) => CropDetail(
      id: json['id'],
      cropType: Crop.fromJson(json['crop_type']),
      crop: Cropinfo.fromJson(json['crop']),
      harvestingType: HarvestingType.fromJson(json['harvesting_type']),
      plantationDate: json['plantation_date'],
      measurementValue: json['measurement_value']?.toDouble() ?? 0.0,
      measurementUnit: MeasurementUnit.fromJson(json['measurement_unit']),
      imageUrl: json['img'],
      description: json['description'] ?? '',
      geoMarks: List<List<double>>.from(
        json['geo_marks']?.map(
              (x) => List<double>.from(x.map((y) => y?.toDouble() ?? 0.0)),
            ) ??
            [],
      ),
    );
}
