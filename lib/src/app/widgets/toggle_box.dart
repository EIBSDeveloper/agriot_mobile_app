import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        decoration: (activePageIndex == index)
            ? BoxDecoration(
                color: Get.theme.colorScheme.primary,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              )
            : BoxDecoration(
                color: Get.theme.colorScheme.secondaryContainer
                
              ),
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
