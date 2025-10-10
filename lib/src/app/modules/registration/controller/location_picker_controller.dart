import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../service/utils/utils.dart';

class LocationPickerController extends GetxController {
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final Rx<CameraPosition> cameraPosition = Rx<CameraPosition>(
    const CameraPosition(target: LatLng(0, 0), zoom: 15),
  );
  final RxBool isLoading = true.obs;
  final RxString address = ''.obs;
  GoogleMapController? mapController;
  @override
  void onInit() {
    super.onInit();
    final argument = Get.arguments;
    double? longitude = argument?["longitude"];
    double? latitude = argument?["latitude"];
    if (longitude != null && latitude != null) {
      selectedLocation.value = LatLng(latitude, longitude);
    }
    loadMap();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading(true);
      Position position = await Geolocator.getCurrentPosition();
      var latLng = LatLng(position.latitude, position.longitude);
      cameraPosition.value = CameraPosition(target: latLng, zoom: 15);
      selectedLocation.value = latLng;
    } catch (e) {
      showError('Error');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMap() async {
    try {
      isLoading(true);
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      if (selectedLocation.value != null) {
        cameraPosition.value = CameraPosition(
          target: LatLng(
            selectedLocation.value!.latitude,
            selectedLocation.value!.longitude,
          ),
          zoom: 15,
        );
        getAddress(selectedLocation.value!);
      } else {
        getCurrentLocation();
      }
    } finally {
      isLoading(false);
    }
  }

  void onMapTap(LatLng location) {
    selectedLocation.value = location;
    getAddress(location);
  }

  Future<void> getAddress(LatLng latLng) async {
    Map addressFromLatLng = await getAddressFromLatLng(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
    address.value = addressFromLatLng['address'] ?? '';
    // pincodeController.text = addressFromLatLng['pincode'] ?? '';
  }

  void confirmSelection() {
    if (selectedLocation.value != null) {
      Get.back(
        result: {
          'latitude': selectedLocation.value!.latitude,
          'longitude': selectedLocation.value!.longitude,
          'address': address.value,
        },
      );
    } else {
      showError('Please select a location');
    }
  }
}
