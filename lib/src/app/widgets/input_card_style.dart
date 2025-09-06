import 'package:flutter/material.dart';

import '../../core/app_style.dart';

class InputCardStyle extends StatelessWidget {
  final Widget child;
  final bool noHeight;
  const InputCardStyle({super.key, this.noHeight = false, required this.child});

  @override
  Widget build(BuildContext context) => Container(
      decoration: AppStyle.inputDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      constraints: noHeight
          ? null
          : const BoxConstraints(
              minHeight: 55, // minimum height for all fields
            ),
      child: child,
    );
}
