import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final T? value;
  final bool enabled;

  const InventoryDropdown({
    Key? key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Get.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Get.theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              hint: Text(hint),
              items: items,
              onChanged: enabled ? onChanged : null,
              value: value,
            ),
          ),
        ),
      ],
    );
  }
}
