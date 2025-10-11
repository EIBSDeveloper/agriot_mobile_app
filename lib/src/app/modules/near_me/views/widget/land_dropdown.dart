// widgets/search_bar.dart

import 'package:argiot/src/app/modules/near_me/model/models.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../service/utils/utils.dart';

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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: DropdownButtonFormField<Land>(
      initialValue: selectedLand,
      padding: EdgeInsets.zero,
      items: lands
          .map(
            (Land land) =>
                DropdownMenuItem<Land>(value: land, child: Text(capitalizeFirstLetter(land.name))),
          )
          .toList(),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'land'.tr,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      ),
    ),
  );
}
