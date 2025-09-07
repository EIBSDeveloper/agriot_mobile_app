import 'package:argiot/src/app/modules/forming/model/crop_card_model.dart';


class Land {
  final int id;
  final String name;
  final double measurementValue;
  final String measurementUnit;
  final int landCropCount;
  final List<CropCardModel> crops;

  Land({
    required this.id,
    required this.name,
    required this.measurementValue,
    required this.measurementUnit,
    required this.landCropCount,
    required this.crops,
  });

  factory Land.fromJson(Map<String, dynamic> json) => Land(
      id: json['id'],
      name: json['name'],
      measurementValue: json['measurement_value'].toDouble(),
      measurementUnit: json['measurement_unit']?['name']??'',
      landCropCount: json['land_crop_count'],
      crops: List<CropCardModel>.from(json['crops'].map((x) => CropCardModel.fromJson(x))),
    );
}
