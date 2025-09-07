import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/input_card_style.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Function(String) onChanged;
  final String? Function(String)? validator;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => InputCardStyle(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon:  Icon(Icons.calendar_today,color: Get.theme.primaryColor,),
            onPressed: () => _selectDate(context),
          ),
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
        onChanged: onChanged,
        validator: (value) => validator?.call(value ?? ''),
      ),
    );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      onChanged(controller.text);
    }
  }
}
