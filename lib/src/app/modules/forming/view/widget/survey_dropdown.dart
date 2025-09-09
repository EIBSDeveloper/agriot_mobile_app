import 'package:flutter/material.dart';

import '../../../registration/model/crop_model.dart';

class SurveyMultiSelect extends StatefulWidget {
  final List<CropSurveyDetail> surveys;
  final List<CropSurveyDetail> selectedSurveys;
  final Function(List<CropSurveyDetail>) onChanged;
  final String label;

  const SurveyMultiSelect({
    super.key,
    required this.surveys,
    required this.selectedSurveys,
    required this.onChanged,
    this.label = 'Survey No',
  });

  @override
  State<SurveyMultiSelect> createState() => _SurveyMultiSelectState();
}

class _SurveyMultiSelectState extends State<SurveyMultiSelect> {
  Future<void> _openMultiSelectDialog() async {
    // Work with a temporary list inside dialog
    final List<CropSurveyDetail> tempSelected = List.from(widget.selectedSurveys);

    final result = await showDialog<List<CropSurveyDetail>>(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
              title: Text(widget.label),
              content: SingleChildScrollView(
                child: Column(
                  children: widget.surveys.map((survey) {
                    final isSelected = tempSelected.contains(survey);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(
                        '${survey.surveyNo} (${survey.surveyMeasurementValue} ${survey.surveyMeasurementUnit})',
                      ),
                      onChanged: (checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            tempSelected.add(survey);
                          } else {
                            tempSelected.remove(survey); // ✅ works with == override
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context, widget.selectedSurveys),
                ),
                ElevatedButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.pop(context, tempSelected),
                ),
              ],
            ),
        ),
    );

    if (result != null) {
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = widget.selectedSurveys.isNotEmpty;

    return GestureDetector(
      onTap: _openMultiSelectDialog,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(137, 221, 234, 234),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with label and arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasSelection ? widget.label : widget.label,
                  style: TextStyle(
                    color: hasSelection ? Colors.black : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
            const SizedBox(height: 6),

            // Selected items as chips
            if (hasSelection)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.selectedSurveys.map((survey) => Chip(
                    label: Text(
                      '${survey.surveyNo} (${survey.surveyMeasurementValue} ${survey.surveyMeasurementUnit})',
                    ),
                    onDeleted: () {
                      final updated = List<CropSurveyDetail>.from(widget.selectedSurveys)
                        ..remove(survey);
                      widget.onChanged(updated);
                    },
                  )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
