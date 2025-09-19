import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputCardStyle extends StatelessWidget {
  final Widget child;
  final bool noHeight;
  final EdgeInsetsGeometry? padding;
  const InputCardStyle({
    super.key,
    this.noHeight = false,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Get.theme.colorScheme.secondaryContainer,
      borderRadius: AppStyle.inputDecoration.borderRadius,
    ),
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    constraints: noHeight
        ? null
        : const BoxConstraints(
            minHeight: 50, // minimum height for all fields
          ),
    child: child,
  );
}
