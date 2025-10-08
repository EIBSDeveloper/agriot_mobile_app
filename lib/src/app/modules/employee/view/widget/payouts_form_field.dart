import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';

class PayoutsFormField extends StatelessWidget {
  final String label;
  final String? value;
  final String? errorText;
  final bool isReadOnly;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final int? maxLines;
  final String? Function(String?)? validator;
  const PayoutsFormField({
    super.key,
    required this.label,
    this.value,
    this.errorText,
    this.isReadOnly = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onTap,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      InputCardStyle(
        padding: const EdgeInsets.all(0),
        child: TextFormField(
          controller: TextEditingController(text: value),
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            errorText: errorText?.isEmpty ?? true ? null : errorText,
            border: InputBorder.none,
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: onChanged,
          onTap: onTap,
        ),
      ),
    ],
  );
}
