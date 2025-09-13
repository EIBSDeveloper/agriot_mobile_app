import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../model/land.dart';
import '../repostroy/forming_repository.dart';

class FormingController extends GetxController {
  final FormingRepository _repository = FormingRepository();
  final RxList<Land> lands = <Land>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxInt expandedLandId = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    fetchLands();
  }

  Future<void> fetchLands() async {
    try {
      isLoading(true);
      error('');
      final result = await _repository.getLandsWithCrops();
      lands.assignAll(result);
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void toggleExpandLand(int landId) {
    expandedLandId.value = expandedLandId.value == landId ? -1 : landId;
  }

  void navigateToLandDetail(int landId) {
    Get.toNamed(Routes.landDetail, arguments: landId)?.then((result) {
      if (result ?? false) {
        fetchLands();
      }
    });
  }
}
