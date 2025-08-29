import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class TopToggleButtons extends StatelessWidget {
  final RxInt selectedTopToggle;
  final void Function(int) onToggle;

  const TopToggleButtons({
    super.key,
    required this.selectedTopToggle,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: List.generate(3, (index) => index == selectedTopToggle.value),
      onPressed: onToggle,
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: Theme.of(context).primaryColor,
      color: Colors.black,
      constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
      children: const [Text('Customer'), Text('Vendor'), Text('Both')],
    );
  }
}
