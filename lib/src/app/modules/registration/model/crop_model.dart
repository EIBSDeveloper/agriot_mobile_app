

class CropSurveyDetail {
  final int id;
  final String surveyNo;
  final String surveyMeasurementValue;
  final String surveyMeasurementUnit;

  CropSurveyDetail({
    required this.id,
    required this.surveyNo,
    required this.surveyMeasurementValue,
    required this.surveyMeasurementUnit,
  });

  factory CropSurveyDetail.fromJson(Map<String, dynamic> json) => CropSurveyDetail(
      id: json['id'],
      surveyNo: json['survey_no'],
      surveyMeasurementValue: json['survey_measurement_value'].toString(),
      surveyMeasurementUnit: json['survey_measurement_unit'].toString(),
    );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CropSurveyDetail && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$surveyNo ($surveyMeasurementValue $surveyMeasurementUnit)';
}



