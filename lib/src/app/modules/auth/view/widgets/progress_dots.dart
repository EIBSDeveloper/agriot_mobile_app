import 'package:argiot/src/app/modules/auth/controller/walkthrough_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressDots extends StatelessWidget {
  final WalkthroughController controller;

  const ProgressDots({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Obx(
    () => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.pages.length,
        (index) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.currentPage.value == index
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
      ),
    ),
  );
}
