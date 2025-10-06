import 'package:argiot/src/app/modules/forming/model/soil_type.dart';

class LandModel {
    final int? id;
    final String? name;
    final int? measurementValue;
    final SoilType? measurementUnit;
    final SoilType? soilType;
    final SoilType? manager;
    final String? doorNo;
    final String? locations;
    final double? latitude;
    final double? longitude;
    final String? pattaNumber;
    final String? description;
    final int? lStatus;
    final List<dynamic>? surveyDetails;
    final int? surveyCount;
    final List<dynamic>? documents;
    final List<dynamic>? cropDetails;
    final int? cropCount;

    LandModel({
        this.id,
        this.name,
        this.measurementValue,
        this.measurementUnit,
        this.soilType,
        this.manager,
        this.doorNo,
        this.locations,
        this.latitude,
        this.longitude,
        this.pattaNumber,
        this.description,
        this.lStatus,
        this.surveyDetails,
        this.surveyCount,
        this.documents,
        this.cropDetails,
        this.cropCount,
    });

    factory LandModel.fromJson(Map<String, dynamic> json) => LandModel(
        id: json["id"],
        name: json["name"],
        measurementValue: json["measurement_value"],
        measurementUnit: json["measurement_unit"] == null ? null : SoilType.fromJson(json["measurement_unit"]),
        soilType: json["soil_type"] == null ? null : SoilType.fromJson(json["soil_type"]),
        manager: json["manager"] == null ? null : SoilType.fromJson(json["manager"]),
        doorNo: json["door_no"],
        locations: json["locations"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        pattaNumber: json["patta_number"]??"",
        description: json["description"]??'',
        lStatus: json["l_status"],
        surveyDetails: json["survey_details"] == null ? [] : List<dynamic>.from(json["survey_details"]!.map((x) => x)),
        surveyCount: json["survey_count"],
        documents: json["documents"] == null ? [] : List<dynamic>.from(json["documents"]!.map((x) => x)),
        cropDetails: json["crop_details"] == null ? [] : List<dynamic>.from(json["crop_details"]!.map((x) => x)),
        cropCount: json["crop_count"],
    );

}
