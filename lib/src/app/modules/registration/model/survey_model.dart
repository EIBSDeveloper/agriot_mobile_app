import './dropdown_item.dart';

class SurveyItem {
  final int? id;
  final String surveyNo;
  final String measurement;
  final AppDropdownItem? unit;

  SurveyItem({
    this.id,
    required this.surveyNo,
    required this.measurement,
    this.unit,
  });

  SurveyItem copyWith({
    String? surveyNo,
    String? measurement,
    AppDropdownItem? unit,
  }) => SurveyItem(
      surveyNo: surveyNo ?? this.surveyNo,
      measurement: measurement ?? this.measurement,
      unit: unit ?? this.unit,
    );
}
