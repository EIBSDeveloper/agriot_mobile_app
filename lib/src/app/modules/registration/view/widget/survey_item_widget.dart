import 'package:flutter/material.dart';

import '../../../../../core/app_style.dart';
import '../../model/dropdown_item.dart';
import '../../model/survey_model.dart';
import 'searchable_dropdown.dart';

class SurveyItemWidget extends StatelessWidget {
  final int index;
  final SurveyItem item;
  final List<AppDropdownItem> areaUnits;
  final VoidCallback onRemove;
  final void Function(SurveyItem) onChanged; // Updated type

  const SurveyItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.areaUnits,
    required this.onRemove,
    required this.onChanged, // Updated parameter
  });

  @override
  Widget build(BuildContext context) => Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Survey Detail #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: AppStyle.decoration.copyWith(
                color: const Color.fromARGB(137, 221, 234, 234),
                boxShadow: const [],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              constraints: const BoxConstraints(
                minHeight: 55, // minimum height for all fields
              ),
              child: TextFormField(
                initialValue: item.surveyNo,
                decoration: const InputDecoration(
                  labelText: 'Survey Number *',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) => onChanged(item.copyWith(surveyNo: value)),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: AppStyle.decoration.copyWith(
                      color: const Color.fromARGB(137, 221, 234, 234),
                      boxShadow: const [],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    height: 55,
                    child: TextFormField(
                      initialValue: item.measurement,
                      decoration: const InputDecoration(
                        labelText: 'Measurement *',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          onChanged(item.copyWith(measurement: value)),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  flex: 2,
                  child: SearchableDropdown<AppDropdownItem>(
                    label: 'Unit *',
                    items: areaUnits,
                    displayItem: (value) => value.name.toString(),
                    selectedItem: item.unit,
                    onChanged: (value) => onChanged(item.copyWith(unit: value)),
                    validator: (value) =>
                        value == null ? 'Required field' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
}
