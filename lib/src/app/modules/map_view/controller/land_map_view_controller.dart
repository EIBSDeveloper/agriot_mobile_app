import 'package:argiot/src/app/modules/map_view/model/crop_details.dart';
import 'package:argiot/src/app/modules/map_view/model/crop_map_data.dart';
import 'package:argiot/src/app/modules/map_view/model/land_map_data.dart';
import 'package:argiot/src/app/modules/map_view/repository/land_map_view_repository.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/dashboad/model/weather_data.dart';
import 'package:argiot/src/app/modules/registration/repostrory/crop_service.dart';
import 'package:argiot/src/app/modules/task/model/schedule_crop.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../utils.dart';

class LandMapViewController extends GetxController {
  final LandMapViewRepository _repository = LandMapViewRepository();
  var isLoading = true.obs;
  final AppDataController appDataController = Get.find();
  var lands = <ScheduleLand>[].obs;
  final Rx<CropDetails?> cropDetails = Rx<CropDetails?>(null);
  var selectedLand = Rxn<ScheduleLand>();
  var selectedCrop = Rxn<ScheduleCrop>();
  final Rx<WeatherData?> weatherData = Rx<WeatherData?>(null);
  var mapType = MapType.normal.obs;
  var cameraPosition = const CameraPosition(
    target: LatLng(12.9716, 77.5946),
    zoom: 14,
  ).obs;
  final ScheduleCrop allCrop = ScheduleCrop(id: 0, name: "All");

  var landpolyline = <LatLng>[].obs;
  Rx<LandMapData?> landMapDetails = Rx<LandMapData?>(null);

  GoogleMapController? mapController;
  LatLngBounds? pendingBounds;
  @override
  void onInit() {
    super.onInit();
    fetchLandsAndCrops();
  }

  Future<void> fetchWeatherData(double lat, double lon) async {
    weatherData.value = await _repository.getWeatherData(lat, lon);
  }

  void updateCameraToPolygon(List<LatLng> polygon) {
    if (polygon.isEmpty) return;

    var bounds = boundsFromLatLngList(polygon);

    if (mapController == null) {
      // ✅ Save it until map is ready
      pendingBounds = bounds;
      return;
    }

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double x0 = list.first.latitude, x1 = list.first.latitude;
    double y0 = list.first.longitude, y1 = list.first.longitude;
    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  List<ScheduleCrop> get cropsForSelectedLand =>
      selectedLand.value?.crops ?? [];

  void changeMapType(MapType type) {
    mapType.value = type;
  }

  Future<void> fetchLandsAndCrops() async {
    try {
      isLoading(true);
      final result = await _repository.fetchLandsAndCrops();
      lands.assignAll(result);

      if (result.isNotEmpty) {
        selectedLand.value = result.first;
        selectedCrop.value = allCrop;
        await fetchLandsAndCropMap();
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchLandsAndCropsDetails(cropId) async {
    try {
      // isLoading(true);
      final result = await _repository.fetcCropDetails(
        selectedLand.value!.id,
        cropId,
      );
      cropDetails.value = result;
    } finally {
      // isLoading(false);
    }
    return;
  }

  Future<Set<Marker>> buildCropMarkers(List<CropMapData> crops) async {
    final markers = <Marker>{};

    for (final crop in crops) {
      if (crop.geoMarks == null || crop.geoMarks!.isEmpty) continue;

      // find center of polygon
      final cropPoints = crop.geoMarks!
          .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
          .toList();
      final center = LatLng(
        cropPoints.map((e) => e.latitude).reduce((a, b) => a + b) /
            cropPoints.length,
        cropPoints.map((e) => e.longitude).reduce((a, b) => a + b) /
            cropPoints.length,
      );

      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

      if (crop.cropImage != null && crop.cropImage!.isNotEmpty) {
        try {
          final bytes = await getBytesFromUrl(crop.cropImage!, width: 120);
          icon = BitmapDescriptor.fromBytes(bytes);
        } catch (e) {
          print("Failed to load crop image: $e");
        }
      }

      markers.add(
        Marker(
          markerId: MarkerId("crop_${crop.cropId}"),
          position: center,
          icon: icon,
          infoWindow: InfoWindow(title: crop.cropName ?? "Crop"),
        ),
      );
    }
    return markers;
  }

  Future<void> fetchLandsAndCropMap() async {
    if (selectedLand.value == null) return;
    final result = await _repository.fetchLandsAndCropMap(
      selectedLand.value!.id,
    );
    landMapDetails.value = result;

    // land polygon
    landpolyline.value = parseLatLngListFromString(
      result.geoMarks ?? [],
    ).toList();
    fetchWeatherData(result.geoMarks![0][0], result.geoMarks![0][1]);
    if (selectedCrop.value?.id == 0) {
      updateCameraToPolygon(landpolyline);
    } else {
      final crop = result.crops?.firstWhere(
        (c) => c.cropId == selectedCrop.value?.id,
        orElse: () => CropMapData(),
      );
      if (crop != null && crop.geoMarks != null && crop.geoMarks!.isNotEmpty) {
        final poly = crop.geoMarks!
            .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
            .toList();
        updateCameraToPolygon(poly);
      }
    }
  }

  void selectLand(ScheduleLand? land) {
    selectedLand.value = land;
    selectedCrop.value = allCrop; //  reset to All
    fetchLandsAndCropMap();
  }

  void selectCrop(ScheduleCrop? crop) {
    selectedCrop.value = crop ?? allCrop;
    fetchLandsAndCropMap(); //  refresh polygons + zoom
  }
}
