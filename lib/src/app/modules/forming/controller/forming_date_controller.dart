import 'package:get/get.dart';

import '../../near_me/model/models.dart';
import '../../registration/repostrory/land_service.dart';

class FormingDateController extends GetxController {
  final LandService _landService = Get.find();
  final RxBool isLoadingLands = false.obs;
  var lands = <Land>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchLands();
  }


  Future<void> fetchLands() async {
    isLoadingLands(true);
    final landList = await _landService.getLands();
    lands.assignAll(landList.lands);
    isLoadingLands(false);
  }
}
