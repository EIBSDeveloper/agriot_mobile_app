
import 'package:argiot/src/app/modules/auth/model/walkthrough_model.dart';
import 'package:argiot/src/app/modules/auth/repository/walkthrough_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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
