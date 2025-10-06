import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../controller/storage_service.dart';
import '../view/screen/crop_view.dart';
import '../view/screen/kyc_view.dart';
import '../view/screen/land_view.dart';

class ResgisterController extends GetxController {
  final StorageService _storageService = Get.put(StorageService());
  RxInt pageIndex = 0.obs;
  ResgisterController() {
    pageIndex.value = Get.arguments ?? 0;
  }
  RxList<bool> completeStatus = [false, false, false].obs;
  RxList<int> detailID = [0, 0, 0].obs;
  List<Widget> pages = [const KycView(), LandView(), const CropView()];
  List<String> title = ['Farmer Details', 'Land Details', 'Crop Details'];

  moveNextPage() async {
    if (pageIndex.value == pages.length - 1) {
      await _storageService.updateLoginState(true);
      Get.offAllNamed((Routes.home));
    } else {
      completeStatus[pageIndex.value]=true;
      pageIndex.value++;
    }
  }

  skip() async {
    await _storageService.updateLoginState(true);
    Get.offAllNamed((Routes.home));
  }

  movePage(int index) {
    pageIndex.value = index;
  }
}
