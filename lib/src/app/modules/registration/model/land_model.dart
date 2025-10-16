import '../../forming/model/measurement_unit.dart';
import '../../forming/model/soil_type.dart';

class LandWithSurvey {
  final int landId;
  final String landName;
  final List<SurveyDetail> surveyDetails;

  LandWithSurvey({
    required this.landId,
    required this.landName,
    required this.surveyDetails,
  });

  factory LandWithSurvey.fromJson(Map<String, dynamic> json) => LandWithSurvey(
      landId: json['land_id'],
      landName: json['land_name'],
      surveyDetails: (json['survey_details'] as List)
          .map((item) => SurveyDetail.fromJson(item))
          .toList(),
    );

  @override
  String toString() => landName;
}

class SurveyDetail {
  int? id;
  String? farmer;
  String? myLand;
  String? surveyNo;
  String? measurementValue;
  String? measurementUnit;

  SurveyDetail({
    this.id,
    this.farmer,
    this.myLand,
    this.surveyNo,
    this.measurementValue,
    this.measurementUnit,
  });

  factory SurveyDetail.fromJson(Map<String, dynamic> json) => SurveyDetail(
    id: json["id"],
    farmer: json["farmer"],
    myLand: json["MyLand"],
    surveyNo: json["survey_no"],
    measurementValue:json["survey_measurement_value"].toString(),
    measurementUnit: json["survey_measurement_unit"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "farmer": farmer,
    "MyLand": myLand,
    "survey_no": surveyNo,
    "survey_measurement_value": measurementValue,
    "survey_measurement_unit": measurementUnit,
  };
}

class LandDetail {
  final int id;
  final String name;
  final double measurementValue;
  final MeasurementUnit measurementUnit;
  final SoilType? manager;
  final SoilType? soilType;
  final String doorNo;
  final String locations;
  final double latitude;
  final double longitude;
  final List geoMarks;
  final String pattaNumber;
  final String? description;

  final String? pincode;
  final String? address;
  final int status;
  final int lStatus;
  final List<SurveyDetail> surveyDetails;
  final List<ApiDocuments> documents;

  LandDetail({
    required this.id,
    required this.name,
    required this.measurementValue,
    required this.measurementUnit,
    this.soilType,
    this.manager,
    required this.doorNo,
    required this.locations,
    required this.latitude,
    required this.longitude,
    required this.geoMarks,
    required this.pattaNumber,
    this.description,
    this.pincode,
    this.address,

    required this.status,
    required this.lStatus,
    required this.surveyDetails,
    required this.documents,
  });

  factory LandDetail.fromJson(Map<String, dynamic> json) => LandDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      measurementValue: (json['measurement_value'] ?? 0).toDouble(),
      measurementUnit: MeasurementUnit.fromJson(json['measurement_unit'] ?? {}),
      soilType: SoilType.fromJson(json['soil_type'] ?? {}),
      manager: SoilType.fromJson(json['manager'] ?? {}),
      doorNo: json['door_no'] ?? '',
      locations: json['locations'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      geoMarks: json['geo_marks'] ?? [],
      pattaNumber: json['patta_number'] ?? '',
      description: json['description'],
      pincode: json['pincode'].toString(),
      address: json['address'],

      status: json['status'] ?? 0,
      lStatus: json['l_status'] ?? 0,
      surveyDetails:
          (json['survey_details'] as List<dynamic>?)
              ?.map((detail) => SurveyDetail.fromJson(detail))
              .toList() ??
          [], 
          documents:
          (json['documents'] as List<dynamic>?)
              ?.map((detail) => ApiDocuments.fromJson(detail))
              .toList() ??
          [],
    
    );
}

class ApiDocuments {
    final int? id;
    final DocumentCate? documentCategory;
    final String? uploadDocument;

    ApiDocuments({
        this.id,
        this.documentCategory,
        this.uploadDocument,
    });

    ApiDocuments copyWith({
        int? id,
        DocumentCate? documentCategory,
        String? uploadDocument,
    }) => 
        ApiDocuments(
            id: id ?? this.id,
            documentCategory: documentCategory ?? this.documentCategory,
            uploadDocument: uploadDocument ?? this.uploadDocument,
        );

    factory ApiDocuments.fromJson(Map<String, dynamic> json) => ApiDocuments(
        id: json["id"],
        documentCategory: json["document_category"] == null ? null : DocumentCate.fromJson(json["document_category"]),
        uploadDocument: json["upload_document"],
    );

    // Map<String, dynamic> toJson() => {
    //     "id": id,
    //     "document_category": documentCategory?.toJson(),
    //     "upload_document": uploadDocument,
    // };
}



class DocumentCate {
    final int? id;
    final String? name;

    DocumentCate({
        this.id,
        this.name,
    });

    DocumentCate copyWith({
        int? id,
        String? name,
    }) => 
        DocumentCate(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory DocumentCate.fromJson(Map<String, dynamic> json) => DocumentCate(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
