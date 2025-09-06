// lib/modules/walkthrough/models/walkthrough_model.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WalkthroughModel {
  final String title;
  final String description;
  final String imagePath;

  WalkthroughModel({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

// lib/modules/walkthrough/repositories/walkthrough_repository.dart

class WalkthroughRepository {
  // Local data for now since it's static content
  List<WalkthroughModel> getLocalWalkthroughData() => [
      WalkthroughModel(
        title: 'landManagement'.tr,
        description: 'landManagementDescription'.tr,
        imagePath: 'assets/image/land_management.png',
      ),
      WalkthroughModel(
        title: 'schedule'.tr,
        description: 'scheduleDescription'.tr,
        imagePath: 'assets/image/schedule.png',
      ),
      WalkthroughModel(
        title: 'costManagement'.tr,
        description: 'costManagementDescription'.tr,
        imagePath: 'assets/image/man_power.png',
      ),
    ];
}
// lib/modules/walkthrough/controllers/walkthrough_controller.dart

class WalkthroughController extends GetxController {
  final WalkthroughRepository _repository = WalkthroughRepository();
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  late final List<WalkthroughModel> pages;

  @override
  void onInit() {
    pages = _repository.getLocalWalkthroughData();
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void navigateToNextPage() {
    if (currentPage.value < pages.length - 1) {
      currentPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void navigateToHome() {
    // Mark walkthrough as completed
    GetStorage().write('walkthrough_completed', true);
    // Navigate to home and prevent going back to walkthrough
    Get.offAllNamed('/home');
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }
}


class WalkthroughView extends GetView<WalkthroughController> {
  const WalkthroughView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _WalkthroughPage(
                    imagePath: page.imagePath,
                    title: page.title,
                    description: page.description,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0, right: 10, left: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _ProgressDots(controller: controller)),
                  Obx(
                    () =>
                        controller.currentPage.value <
                            controller.pages.length - 1
                        ? _NextButton(onPressed: controller.navigateToNextPage)
                        : _StartButton(onPressed: controller.navigateToHome),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

class _WalkthroughPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _WalkthroughPage({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              description,
              style: Get.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
}

class _ProgressDots extends StatelessWidget {
  final WalkthroughController controller;

  const _ProgressDots({required this.controller});

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

class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NextButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Get.theme.colorScheme.primary, width: 2),
        ),
        child: Icon(Icons.arrow_forward, color: Get.theme.colorScheme.primary),
      ),
    );
}

class _StartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _StartButton({required this.onPressed});

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

