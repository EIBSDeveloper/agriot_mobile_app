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
        backgroundColor: const Color.fromARGB(223, 229, 235, 209),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() => MinimalHorizontalStepper(
                steps: const ['KYC', 'Land', 'Crop'],
                currentStep: controller.pageIndex.value,
              ))
             ,
              Obx(() => controller.pages[controller.pageIndex.value]),
            ],
          ),
        ),
      ),
    );
  }
}
