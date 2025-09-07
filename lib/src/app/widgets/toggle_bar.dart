import 'package:argiot/src/app/widgets/toggle_box.dart';
import 'package:flutter/material.dart';
import '../../core/app_style.dart';

class ToggleBar extends StatelessWidget {
  const ToggleBar({
    super.key,
    required this.onTap,
    required this.activePageIndex,
    required this.buttonsList,
  });
  final void Function(int)? onTap;
  final int activePageIndex;
  final List<String> buttonsList;

  @override
  Widget build(BuildContext context) => Container(
    height: 50.0,
    decoration: AppStyle.decoration,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ...List.generate(
          buttonsList.length,
          (index) => ToggleBox(
            onTap: onTap,
            activePageIndex: activePageIndex,
            lable: buttonsList[index],
            index: index,
          ),
        ),
      ],
    ),
  );
}
