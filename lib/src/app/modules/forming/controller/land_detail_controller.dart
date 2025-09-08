import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../service/utils/utils.dart';
import '../repostroy/forming_repository.dart';

class LandDetailController extends GetxController {
  final FormingRepository _repository = FormingRepository();

  final RxMap<String, dynamic> landDetails = <String, dynamic>{}.obs;
  final RxBool isLoading = true.obs;
  final RxInt landId = 0.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    landId.value = Get.arguments as int;
    loadData();
  }

  void loadData() {
    fetchLandDetails(landId.value);
  }

  Future<void> fetchLandDetails(int landId) async {
    try {
      isLoading(true);
      error('');
      final result = await _repository.getLandDetails(landId);
      landDetails.assignAll(result);
    } catch (e) {
      error(e.toString());
      showError('Failed to load land details');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteLandDetails(int landId) async {
    try {
      isLoading(true);
      error('');
      final result = await _repository.daleteLandDetails(landId);
      Get.back();
      showSuccess(result["message"]);
    } catch (e) {
      error(e.toString());
      showError('Failed to delete land details');
    } finally {
      isLoading(false);
    }
  }



  void viewOnMap(double latitude, double longitude) {
    if (latitude != 0 && longitude != 0) {
      Get.toNamed(
        Routes.locationViewer,
        arguments: {'latitude': latitude, 'longitude': longitude},
      );
    } else {
      showError('Location not available');
    }
  }
}
