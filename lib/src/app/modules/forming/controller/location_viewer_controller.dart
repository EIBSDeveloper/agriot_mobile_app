import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationViewerController extends GetxController {
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString address = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    latitude.value = args['latitude'] ?? 0.0;
    longitude.value = args['longitude'] ?? 0.0;
    _getAddress();
  }

  Future<void> _getAddress() async {
    try {
      if (latitude.value == 0.0 || longitude.value == 0.0) return;
      
      final placemarks = await placemarkFromCoordinates(
        latitude.value,
        longitude.value,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address.value = '${place.street}, ${place.locality}, ${place.country}';
      }
    } finally {
      isLoading(false);
    }
  }
}