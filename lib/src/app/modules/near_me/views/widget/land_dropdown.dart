// widgets/search_bar.dart

import 'package:argiot/src/app/modules/near_me/model/models.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';

class LandDropdown extends StatelessWidget {
  final List<Land> lands;
  final Land selectedLand;
  final Color? color;
  final Function(Land?) onChanged;

  const LandDropdown({
    super.key,
    required this.lands,
    this.color,
    required this.selectedLand,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => InputCardStyle(
     
      child: DropdownButtonFormField<Land>(
        initialValue: selectedLand,
        items: lands.map((Land land) => DropdownMenuItem<Land>(value: land, child: Text(land.name))).toList(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        onChanged: onChanged,
        decoration: const InputDecoration(
          // labelText: 'Land',
          border: InputBorder.none,

          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
}
