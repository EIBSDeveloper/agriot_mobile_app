import 'package:argiot/src/app/modules/registration/model/crop_model.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';

class SurveyDropdown extends StatelessWidget {
  final List<CropSurveyDetail> surveys;
  final CropSurveyDetail? selectedSurvey;
  final bool addNew;
  final Function(CropSurveyDetail?) onChanged;
  final String label;

  const SurveyDropdown({
    super.key,
    required this.surveys,
    required this.selectedSurvey,
    required this.onChanged,
    this.addNew = false,
    this.label = 'Survey No',
  });

  @override
  Widget build(BuildContext context) => Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: DropdownButtonFormField<CropSurveyDetail>(
        value: surveys.contains(selectedSurvey) ? selectedSurvey : null,
        
                icon: const Icon(Icons.keyboard_arrow_down),
        items: surveys.map((CropSurveyDetail survey) => DropdownMenuItem(
            value: survey,
            child: Text(
              '${survey.surveyNo} (${survey.surveyMeasurementValue} ${survey.surveyMeasurementUnit})',
            ),
          )).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
}
