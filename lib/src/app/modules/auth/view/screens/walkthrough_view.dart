import 'package:argiot/src/app/modules/auth/controller/walkthrough_controller.dart';
import 'package:argiot/src/app/modules/auth/view/screens/walkthrough_page.dart';
import 'package:argiot/src/app/modules/auth/view/widgets/next_button.dart';
import 'package:argiot/src/app/modules/auth/view/widgets/progress_dots.dart';
import 'package:argiot/src/app/modules/auth/view/widgets/start_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                return WalkthroughPage(
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
                Expanded(child: ProgressDots(controller: controller)),
                Obx(
                  () =>
                      controller.currentPage.value < controller.pages.length - 1
                      ? NextButton(onPressed: controller.navigateToNextPage)
                      : StartButton(onPressed: controller.navigateToHome),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
