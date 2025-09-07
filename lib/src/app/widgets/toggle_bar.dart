import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          ...List.generate(buttonsList.length, (index) => ToggleBox(
              onTap: onTap,
              activePageIndex: activePageIndex,
              lable: buttonsList[index],
              index: index,
            )),
        ],
      ),
    );
}

class ToggleBox extends StatelessWidget {
  const ToggleBox({
    super.key,
    required this.onTap,
    required this.lable,
    required this.activePageIndex,
    required this.index,
  });

  final void Function(int p1)? onTap;
  final int activePageIndex;
  final String lable;
  final int index;

  @override
  Widget build(BuildContext context) => Expanded(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: () => onTap?.call(index),
        child: Container(
          alignment: Alignment.center,
          decoration:
              (activePageIndex == index)
                  ? BoxDecoration(
                    color: Get.theme.colorScheme.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  )
                  : null,
          child: Text(
            lable,
            style: Get.theme.textTheme.bodyLarge!.copyWith(
              color: (activePageIndex == index) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
}
