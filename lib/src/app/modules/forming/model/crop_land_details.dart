import 'package:argiot/src/app/modules/forming/model/measurement_unit.dart';
import 'package:argiot/src/app/modules/forming/model/soil_type.dart';
import 'package:argiot/src/app/modules/registration/model/land_model.dart';

class CropLandDetails {
  final int id;
  final String name;
  final double measurementValue;
  final MeasurementUnit measurementUnit;
  final SoilType soilType;
  final List<SurveyDetail> surveyDetails;
  final String pattaNumber;
  final double latitude;
  final double longitude;

  CropLandDetails({
    required this.id,
    required this.name,
    required this.measurementValue,
    required this.measurementUnit,
    required this.soilType,
    required this.surveyDetails,
    required this.pattaNumber,
    required this.latitude,
    required this.longitude,
  });

  factory CropLandDetails.fromJson(Map<String, dynamic> json) => CropLandDetails(
      id: json['id'],
      name: json['name'],
      measurementValue: json['measurement_value']?.toDouble() ?? 0.0,
      measurementUnit: MeasurementUnit.fromJson(json['measurement_unit']),
      soilType: SoilType.fromJson(json['soil_type']),
      surveyDetails: List<SurveyDetail>.from(
        json['survey_details']?.map((x) => SurveyDetail.fromJson(x)) ?? [],
      ),
      pattaNumber: json['patta_number'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
}
