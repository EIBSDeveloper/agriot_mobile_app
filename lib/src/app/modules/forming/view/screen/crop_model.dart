import 'package:argiot/src/app/modules/forming/model/measurement_unit.dart';
import 'package:argiot/src/app/modules/registration/model/land_model.dart';

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

// Supporting models
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

class Cropinfo {
  final int id;
  final String name;
  final String? cropType;
  final String? imageUrl;
  final String? description;
  final double? totalSales;
  final double? totalExpenses;

  Cropinfo({
    required this.id,
    required this.name,
    this.cropType,
    this.imageUrl,
    this.description,
    this.totalSales,
    this.totalExpenses,
  });

  factory Cropinfo.fromJson(Map<String, dynamic> json) => Cropinfo(
      id: json['id'] ?? json['crop_id'] ?? 0,
      name: json['name'] ?? json['crop'] ?? '',
      cropType: json['crop_type'],
      imageUrl: json['img'],
      description: json['description'],
      totalSales: json['total_sales_amount']?.toDouble(),
      totalExpenses: json['total_expenses_amount']?.toDouble(),
    );
}

class CropGuideline {
  final int id;
  final String name;
  final String description;
  final String videoUrl;
  final String? document;
  final String mediaType;

  CropGuideline({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    this.document,
    required this.mediaType,
  });

  factory CropGuideline.fromJson(Map<String, dynamic> json) => CropGuideline(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      videoUrl: json['video_url'] ?? "",
      document: json['document'],
      mediaType: json['media_type'],
    );
}

class Schedule {
  final int id;
  final String activityType;
  final String startDate;
  final String endDate;
  final String status;
  final String schedule;
  final String comment;

  Schedule({
    required this.id,
    required this.activityType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.schedule,
    required this.comment,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
      id: json['schedule_id'],
      activityType: json['schedule_activity_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['schedule_status'],
      schedule: json['schedule']??" ",
      comment: json['comment'] ?? '',
    );
}


class Crop {
  final int id;
  final String name;
  final String img;

  Crop({required this.id, required this.name, required this.img});

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      img: json['img'] ?? '',
    );
    
  Map<String, dynamic> toJson() => {"id": id, "name": name};
}


class HarvestingType {
  final int id;
  final String name;

  HarvestingType({required this.id, required this.name});

  factory HarvestingType.fromJson(Map<String, dynamic> json) => HarvestingType(id: json['id'], name: json['name']);
}

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
