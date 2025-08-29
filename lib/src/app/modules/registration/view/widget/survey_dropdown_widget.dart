import 'package:flutter/material.dart';
import '../../model/crop_model.dart';

class SurveyDropdownWidget extends StatelessWidget {
  final List<CropSurveyDetail> surveys;
  final CropSurveyDetail? selectedSurvey;
  final Function(CropSurveyDetail?) onChanged;

  const SurveyDropdownWidget({
    super.key,
    required this.surveys,
    required this.selectedSurvey,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CropSurveyDetail>(
      value: selectedSurvey,
      decoration: InputDecoration(
        labelText: 'Survey Number *',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: surveys.map((survey) {
        return DropdownMenuItem<CropSurveyDetail>(
          value: survey,
          child: Text('${survey.surveyNo} (${survey.surveyMeasurementValue} ${survey.surveyMeasurementUnit})'),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Required field' : null,
      isExpanded: true,
    );
  }
}