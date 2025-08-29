import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../repostrory/crop_service.dart';

class LandPickerController extends GetxController {
  var isLoading = true.obs;

  var cameraPosition = CameraPosition(
    target: LatLng(12.9716, 77.5946), // Default to Bangalore
    zoom: 14,
  ).obs;

  var selectedLocation = Rxn<LatLng>();
  var address = ''.obs;

  var landpolyiline = <LatLng>[].obs;
  var zoom = false.obs;
  var croppolyiline = <LatLng>[].obs;
  var polylinePoints = <LatLng>[].obs;
  // var polylines = <Polyline>{}.obs;

  GoogleMapController? mapController;

  void getCurrentLocation() async {
    isLoading.value = true;

    if (landpolyiline.isNotEmpty || croppolyiline.isNotEmpty) {
      if (croppolyiline.isNotEmpty) {
        polylinePoints.value = croppolyiline;
      }
      LatLng pos = zoom.value ? croppolyiline.first : landpolyiline.first;
      cameraPosition.value = CameraPosition(target: pos, zoom: 15);
      cameraPosition.value = CameraPosition(target: pos, zoom: 17);
    } else {
      Position position = await Geolocator.getCurrentPosition();
      cameraPosition.value = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      );
      LatLng pos = LatLng(position.latitude, position.longitude);

      cameraPosition.value = CameraPosition(target: pos, zoom: 17);
    }

    isLoading.value = false;
  }

  void onMapTap(LatLng tappedPoint) {
    selectedLocation.value = tappedPoint;
    // getAddressFromLatLng(tappedPoint);

    polylinePoints.add(tappedPoint);
    update();
  }

  void clearPolyline() {
    polylinePoints.clear();
    update();
  }

  void confirmSelection() {
    // handle confirm action

    print(polylinePoints);
    Get.back(result: convertLatLngListToList(polylinePoints));
  }
}

