import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart' as geolocator;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


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
    getCurrentLocation();
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
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

      Position position = await Geolocator.getCurrentPosition();
      cameraPosition.value = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      );
    } catch (e) {
      showError('Error');
    } finally {
      isLoading(false);
    }
  }

  void onMapTap(LatLng location) {
    selectedLocation.value = location;
    getAddressFromLatLng(location);
  }

  Future<void> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await geolocator.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        address.value = '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      address.value = 'Coordinates: ${latLng.latitude}, ${latLng.longitude}';
    }
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
