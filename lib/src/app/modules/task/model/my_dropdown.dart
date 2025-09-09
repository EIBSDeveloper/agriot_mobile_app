// lib/app/modules/task/views/task_view.dart

import 'package:argiot/src/app/modules/task/model/named_item.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';

class MyDropdown<T extends NamedItem> extends StatelessWidget {
  final List<T> items;
  final String label;
  final bool disabled;
  final T? selectedItem;
  final void Function(T?) onChanged;
  final String? hintText;
  final EdgeInsetsGeometry? padding;
  final InputBorder? border;

  const MyDropdown({
    super.key,

    required this.items,
    required this.label,
    this.disabled = false,
    required this.selectedItem,
    required this.onChanged,
    this.hintText,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) => InputCardStyle(
    // padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<T>(
      key: key,
      initialValue: selectedItem,
      decoration: InputDecoration(
        hintText: label,
        border: InputBorder.none,
        // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      icon: const Icon(Icons.keyboard_arrow_down),
      hint: hintText != null ? Text(hintText!) : null,
      items: items
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: disabled ? Colors.grey : null),
              ),
            ),
          )
          .toList(),
      onChanged: disabled ? null : onChanged,
      isExpanded: true,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: disabled ? Colors.grey : null),
      validator: (value) {
        if (value == null) {
          return 'Please select a $label';
        }
        return null;
      },
    ),
  );
}
