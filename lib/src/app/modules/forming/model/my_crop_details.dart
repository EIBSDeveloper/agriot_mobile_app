import 'package:argiot/src/app/modules/forming/model/crop.dart';
import 'package:argiot/src/app/modules/registration/model/land_model.dart';

class MyCropDetails {
  int? id;
  Crop? cropType;
  Crop? crop;
  Crop? harvestingType;
  DateTime? plantationDate;
  Crop? land;
  dynamic soilType;
  Crop? taluk;
  Crop? village;
  int? measurementValue;
  Crop? measurementUnit;
  String? description;
  String? imageUrl;

  List? geoMarks;
  List<SurveyDetail>? surveyDetails;

  MyCropDetails({
    this.id,
    this.cropType,
    this.crop,
    this.harvestingType,
    this.plantationDate,
    this.land,
    this.soilType,
    this.measurementValue,
    this.measurementUnit,
    this.description,
    this.imageUrl,
    this.geoMarks,
    this.surveyDetails,
  });

  factory MyCropDetails.fromJson(Map<String, dynamic> json) => MyCropDetails(
    id: json["id"],

    cropType: json["crop_type"] == null
        ? null
        : Crop.fromJson(json["crop_type"]),
    crop: json["crop"] == null ? null : Crop.fromJson(json["crop"]),
    harvestingType: json["harvesting_type"] == null
        ? null
        : Crop.fromJson(json["harvesting_type"]),
    plantationDate: json["plantation_date"] == null
        ? null
        : DateTime.parse(json["plantation_date"]),
    land: json["land"] == null ? null : Crop.fromJson(json["land"]),
    soilType: json["soil_type"],

    measurementValue: json["measurement_value"].round(),
    measurementUnit: json["measurement_unit"] == null
        ? null
        : Crop.fromJson(json["measurement_unit"]),
    description: json["description"],
    imageUrl: json["crop_image"],
    geoMarks: json["geo_marks"] ?? [],
    surveyDetails: json["survey_details"] == null
        ? []
        : List<SurveyDetail>.from(
            json["survey_details"]!.map((x) => SurveyDetail.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "crop_type": cropType?.toJson(),
    "crop": crop?.toJson(),
    "harvesting_type": harvestingType?.toJson(),
    "plantation_date":
        "${plantationDate!.year.toString().padLeft(4, '0')}-${plantationDate!.month.toString().padLeft(2, '0')}-${plantationDate!.day.toString().padLeft(2, '0')}",
    "land": land?.toJson(),
    "soil_type": soilType,

    "measurement_value": measurementValue,
    "measurement_unit": measurementUnit?.toJson(),
    "description": description,

    "geo_marks": geoMarks == null
        ? []
        : List<dynamic>.from(
            geoMarks!.map((x) => List<dynamic>.from(x.map((x) => x))),
          ),
    "survey_details": surveyDetails == null
        ? []
        : List<dynamic>.from(surveyDetails!.map((x) => x.toJson())),
  };
}
