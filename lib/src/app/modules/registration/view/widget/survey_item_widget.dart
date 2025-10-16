import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/input_card_style.dart';
import '../../model/dropdown_item.dart';
import '../../model/survey_model.dart';
import 'searchable_dropdown.dart';

class SurveyItemWidget extends StatelessWidget {
  final int index;
  final SurveyItem item;
  final List<AppDropdownItem> areaUnits;
  final VoidCallback onRemove;
  final void Function(SurveyItem) onChanged; 

  const SurveyItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.areaUnits,
    required this.onRemove,
    required this.onChanged, 
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
                "${'survey_detail_number'.tr} ${index + 1}"
                ,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          InputCardStyle(
            child: TextFormField(
              initialValue: item.surveyNo,
              decoration: InputDecoration(
                labelText: '${'survey_number'.tr} *',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) => onChanged(item.copyWith(surveyNo: value)),
              validator: (value) => value!.isEmpty ? 'required_field'.tr : null,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InputCardStyle(
                  child: TextFormField(
                    initialValue: item.measurement,
                    decoration: InputDecoration(
                      labelText: '${'measurement'.tr} *',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        onChanged(item.copyWith(measurement: value)),
                    validator: (value) =>
                        value!.isEmpty ? 'required_field'.tr : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                flex: 2,
                child: SearchableDropdown<AppDropdownItem>(
                  label: '${'unit'.tr} *',
                  items: areaUnits,
                  displayItem: (value) => value.name.toString(),
                  selectedItem: item.unit,
                  onChanged: (value) => onChanged(item.copyWith(unit: value)),
                  validator: (value) =>
                      value == null ? 'required_field'.tr : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
