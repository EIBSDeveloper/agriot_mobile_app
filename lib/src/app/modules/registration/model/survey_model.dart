import './dropdown_item.dart';

class SurveyItem {
  final int? id;
  final String surveyNo;
  final String measurement;
  final DropdownItem? unit;

  SurveyItem({
    this.id,
    required this.surveyNo,
    required this.measurement,
    this.unit,
  });

  SurveyItem copyWith({
    String? surveyNo,
    String? measurement,
    DropdownItem? unit,
  }) {
    return SurveyItem(
      surveyNo: surveyNo ?? this.surveyNo,
      measurement: measurement ?? this.measurement,
      unit: unit ?? this.unit,
    );
  }
}
