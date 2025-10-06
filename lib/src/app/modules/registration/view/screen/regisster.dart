import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/resgister_controller.dart';
import 'stepper.dart';

class Registration extends GetView<ResgisterController> {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    controller.pageIndex.value = Get.arguments ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.title[controller.pageIndex.value]),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.pageIndex.value > 0) {
              return Container(
                decoration: AppStyle.decoration.copyWith(
                  color: Get.theme.primaryColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: InkWell(
                  onTap: controller.skip,
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
        backgroundColor: Get.theme.colorScheme.primaryContainer,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(
                () => MinimalHorizontalStepper(
                  steps: const ['KYC', 'Land', 'Crop'],
                  currentStep: controller.pageIndex.value,
                  activeColor: Get.theme.primaryColor,
                  top: (int index) {
                    if (controller.completeStatus[index]) {
                      controller.pageIndex.value = index;
                    }
                  },
                ),
              ),
              Obx(() => controller.pages[controller.pageIndex.value]),
            ],
          ),
        ),
      ),
    );
  }
}
