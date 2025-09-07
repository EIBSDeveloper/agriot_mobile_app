import 'package:argiot/src/app/modules/forming/model/crop.dart';
import 'package:argiot/src/app/modules/registration/model/land_model.dart';

class MyCropDetails {
  int? id;
  Crop? farmer;
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
  int? status;
  DateTime? createdAt;
  dynamic createdBy;
  DateTime? updatedAt;
  dynamic updatedBy;
  List? geoMarks;
  dynamic expense;
  dynamic sales;
  int? cropStatus;
  List<SurveyDetail>? surveyDetails;

  MyCropDetails({
    this.id,
    this.farmer,
    this.cropType,
    this.crop,
    this.harvestingType,
    this.plantationDate,
    this.land,
    this.soilType,
    this.taluk,
    this.village,
    this.measurementValue,
    this.measurementUnit,
    this.description,
    this.imageUrl,
    this.status,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.geoMarks,
    this.expense,
    this.sales,
    this.cropStatus,
    this.surveyDetails,
  });

  factory MyCropDetails.fromJson(Map<String, dynamic> json) => MyCropDetails(
    id: json["id"],
    farmer: json["farmer"] == null ? null : Crop.fromJson(json["farmer"]),
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
    taluk: json["taluk"] == null ? null : Crop.fromJson(json["taluk"]),
    village: json["village"] == null ? null : Crop.fromJson(json["village"]),
    measurementValue: json["measurement_value"].round(),
    measurementUnit: json["measurement_unit"] == null
        ? null
        : Crop.fromJson(json["measurement_unit"]),
    description: json["description"],
    imageUrl: json["crop_image"],
    status: json["status"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    createdBy: json["created_by"],
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
    updatedBy: json["updated_by"],
    geoMarks: json["geo_marks"] ?? [],
    expense: json["expense"],
    sales: json["sales"],
    cropStatus: json["crop_status"],
    surveyDetails: json["survey_details"] == null
        ? []
        : List<SurveyDetail>.from(
            json["survey_details"]!.map((x) => SurveyDetail.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "farmer": farmer?.toJson(),
    "crop_type": cropType?.toJson(),
    "crop": crop?.toJson(),
    "harvesting_type": harvestingType?.toJson(),
    "plantation_date":
        "${plantationDate!.year.toString().padLeft(4, '0')}-${plantationDate!.month.toString().padLeft(2, '0')}-${plantationDate!.day.toString().padLeft(2, '0')}",
    "land": land?.toJson(),
    "soil_type": soilType,
    "taluk": taluk?.toJson(),
    "village": village?.toJson(),
    "measurement_value": measurementValue,
    "measurement_unit": measurementUnit?.toJson(),
    "description": description,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "created_by": createdBy,
    "updated_at": updatedAt?.toIso8601String(),
    "updated_by": updatedBy,
    "geo_marks": geoMarks == null
        ? []
        : List<dynamic>.from(
            geoMarks!.map((x) => List<dynamic>.from(x.map((x) => x))),
          ),
    "expense": expense,
    "sales": sales,
    "crop_status": cropStatus,
    "survey_details": surveyDetails == null
        ? []
        : List<dynamic>.from(surveyDetails!.map((x) => x.toJson())),
  };
}
