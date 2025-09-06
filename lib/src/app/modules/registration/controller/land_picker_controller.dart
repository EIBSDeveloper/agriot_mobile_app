import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../repostrory/crop_service.dart';

class LandPickerController extends GetxController {
  var isLoading = true.obs;
  var cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 14).obs;
  var selectedLocation = Rxn<LatLng>();
  var address = ''.obs;
  var landPolylin = <LatLng>[].obs;
    final RxList<List<LatLng>?> priviesCropCoordinates = <List<LatLng>?>[].obs;
  var zoom = false.obs;
  var croppolyiline = <LatLng>[].obs;
  var polylinePoints = <LatLng>[].obs;

  GoogleMapController? mapController;

  void getCurrentLocation() async {
    isLoading.value = true;

    if (landPolylin.isNotEmpty || croppolyiline.isNotEmpty) {
      if (croppolyiline.isNotEmpty) {
        polylinePoints.value = croppolyiline;
      }
      LatLng pos = zoom.value ? croppolyiline.first : landPolylin.first;
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
  
    // Check if tapped point is inside the main polygon
    if (landPolylin.isEmpty||_isPointInPolygon(tappedPoint, landPolylin)) {
      selectedLocation.value = tappedPoint;
      polylinePoints.add(tappedPoint);
      update();
    } else {
      Fluttertoast.showToast(
        msg: "You cannot mark outside the land boundary",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void clearPolyline() {
    polylinePoints.clear();
    update();
  }

  void confirmSelection() {
    Get.back(result: convertLatLngListToList(polylinePoints));
  }

  /// Ray-casting algorithm to check if a point is inside polygon
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1; // odd = inside, even = outside
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double px = point.longitude;
    double py = point.latitude;
    double ax = vertA.longitude;
    double ay = vertA.latitude;
    double bx = vertB.longitude;
    double by = vertB.latitude;

    if ((ay > py && by > py) || (ay < py && by < py) || (ax < px && bx < px)) {
      return false;
    }

    double m = (by - ay) / (bx - ax);
    double x = (py - ay) / m + ax;
    return x > px;
  }
}
