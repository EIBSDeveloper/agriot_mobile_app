import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    ),
    child: Text(
      'letsStart'.tr,
      style: Get.textTheme.labelLarge?.copyWith(
        color: Get.theme.colorScheme.onPrimary,
      ),
    ),
  );
}
