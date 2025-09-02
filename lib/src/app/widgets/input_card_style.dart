import 'package:flutter/material.dart';

import '../../core/app_style.dart';

class InputCardStyle extends StatelessWidget {
  final Widget child;
  final bool noHeight;
  const InputCardStyle({super.key, this.noHeight =false,required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.inputDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: noHeight?null:55,
      child: child,
    );
  }
}
