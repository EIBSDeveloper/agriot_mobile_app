class LandWithSurvey {
  final int landId;
  final String landName;
  final List<SurveyDetail> surveyDetails;

  LandWithSurvey({
    required this.landId,
    required this.landName,
    required this.surveyDetails,
  });

  factory LandWithSurvey.fromJson(Map<String, dynamic> json) {
    return LandWithSurvey(
      landId: json['land_id'],
      landName: json['land_name'],
      surveyDetails: (json['survey_details'] as List)
          .map((item) => SurveyDetail.fromJson(item))
          .toList(),
    );
  }

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
    measurementValue: json["survey_measurement_value"].toString(),
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

// lib/common/models/land_detail_model.dart
class LandDetail {
  final int id;
  final String name;
  final double measurementValue;
  final MeasurementUnit measurementUnit;
  final SoilType? soilType;
  final Country country;
  final State state;
  final City city;
  final Taluk taluk;
  final Village village;
  final String doorNo;
  final String locations;
  final double latitude;
  final double longitude;
  final List geoMarks;
  final String pattaNumber;
  final String? description;
  final String? code;
  final int status;
  final int lStatus;
  final String createdAt;
  final CreatedBy createdBy;
  final String updatedAt;
  final dynamic updatedBy;
  final TranslateJson translateJson;
  final List<SurveyDetail> surveyDetails;
  final List<dynamic> documents;

  LandDetail({
    required this.id,
    required this.name,
    required this.measurementValue,
    required this.measurementUnit,
    this.soilType,
    required this.country,
    required this.state,
    required this.city,
    required this.taluk,
    required this.village,
    required this.doorNo,
    required this.locations,
    required this.latitude,
    required this.longitude,
    required this.geoMarks,
    required this.pattaNumber,
    this.description,
    this.code,
    required this.status,
    required this.lStatus,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    this.updatedBy,
    required this.translateJson,
    required this.surveyDetails,
    required this.documents,
  });

  factory LandDetail.fromJson(Map<String, dynamic> json) {
    return LandDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      measurementValue: (json['measurement_value'] ?? 0).toDouble(),
      measurementUnit: MeasurementUnit.fromJson(json['measurement_unit'] ?? {}),
      soilType: SoilType.fromJson(json['soil_type'] ?? {}),
      country: Country.fromJson(json['country'] ?? {}),
      state: State.fromJson(json['state'] ?? {}),
      city: City.fromJson(json['city'] ?? {}),
      taluk: Taluk.fromJson(json['taluk'] ?? {}),
      village: Village.fromJson(json['village'] ?? {}),
      doorNo: json['door_no'] ?? '',
      locations: json['locations'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      geoMarks: json['geo_marks'] ?? [],
      pattaNumber: json['patta_number'] ?? '',
      description: json['description'],
      code: json['code'],
      status: json['status'] ?? 0,
      lStatus: json['l_status'] ?? 0,
      createdAt: json['created_at'] ?? '',
      createdBy: CreatedBy.fromJson(json['created_by'] ?? {}),
      updatedAt: json['updated_at'] ?? '',
      updatedBy: json['updated_by'],
      translateJson: TranslateJson.fromJson(json['translate_json'] ?? {}),
      surveyDetails:
          (json['survey_details'] as List<dynamic>?)
              ?.map((detail) => SurveyDetail.fromJson(detail))
              .toList() ??
          [],
      documents: json['documents'] ?? [],
    );
  }
}

class SoilType {
  final int? id;
  final String? name;

  SoilType({required this.id, required this.name});

  factory SoilType.fromJson(Map<String, dynamic> json) {
    return SoilType(id: json['id'], name: json['name']);
  }
}

class MeasurementUnit {
  final int id;
  final String name;

  MeasurementUnit({required this.id, required this.name});

  factory MeasurementUnit.fromJson(Map<String, dynamic> json) {
    return MeasurementUnit(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Country {
  final int id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class State {
  final int id;
  final String name;

  State({required this.id, required this.name});

  factory State.fromJson(Map<String, dynamic> json) {
    return State(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Taluk {
  final int id;
  final String name;

  Taluk({required this.id, required this.name});

  factory Taluk.fromJson(Map<String, dynamic> json) {
    return Taluk(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class Village {
  final int id;
  final String name;

  Village({required this.id, required this.name});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class CreatedBy {
  final int id;

  CreatedBy({required this.id});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(id: json['id'] ?? 0);
  }
}

class TranslateJson {
  final Map<String, dynamic> name;
  final Map<String, dynamic> doorNo;
  final Map<String, dynamic> description;

  TranslateJson({
    required this.name,
    required this.doorNo,
    required this.description,
  });

  factory TranslateJson.fromJson(Map<String, dynamic> json) {
    return TranslateJson(
      name: Map<String, dynamic>.from(json['name'] ?? {}),
      doorNo: Map<String, dynamic>.from(json['door_no'] ?? {}),
      description: Map<String, dynamic>.from(json['description'] ?? {}),
    );
  }
}
