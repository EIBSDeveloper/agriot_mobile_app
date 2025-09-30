
import 'package:argiot/src/app/modules/map_view/model/crop_details.dart';
import 'package:argiot/src/app/modules/map_view/model/crop_map_data.dart';
import 'package:argiot/src/app/modules/map_view/model/land_map_data.dart';
import 'package:argiot/src/app/modules/map_view/repository/land_map_view_repository.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/dashboad/model/weather_data.dart';
import 'package:argiot/src/app/modules/registration/repostrory/crop_service.dart';
import 'package:argiot/src/app/modules/task/model/schedule_crop.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../service/utils/utils.dart';
import '../view/widgets/crop_details_bottom_sheet.dart';
// ======================= CONTROLLER =======================

class LandMapViewController extends GetxController {
  // Variables
  final LandMapViewRepository _repository = LandMapViewRepository();
  final AppDataController appDataController = Get.find();
  final ScheduleCrop allCrop = ScheduleCrop(id: 0, name: "All");

  RxBool isLoading = true.obs;
  RxBool isRefreshing = false.obs;
  RxList<ScheduleLand> lands = <ScheduleLand>[].obs;
  RxList<LatLng> landpolyline = <LatLng>[].obs;
  Rxn<ScheduleLand> selectedLand = Rxn<ScheduleLand>();
  Rxn<ScheduleCrop> selectedCrop = Rxn<ScheduleCrop>();
  Rx<MapType> mapType = MapType.normal.obs;
  Rx<CameraPosition> cameraPosition = const CameraPosition(
    target: LatLng(12.9716, 77.5946),
    zoom: 14,
  ).obs;

  final Rx<CropDetails?> cropDetails = Rx<CropDetails?>(null);
  final Rx<WeatherData?> weatherData = Rx<WeatherData?>(null);
  Rx<LandMapData?> landMapDetails = Rx<LandMapData?>(null);
  final RxInt landId = 0.obs;
  final RxInt cropId = 0.obs;

  GoogleMapController? mapController;
  LatLngBounds? pendingBounds;
  final polygons = <Polygon>{}.obs;
  final markers = <Marker>{}.obs;

 
  final List<Color> cropColors = [
    Colors.red,
    Colors.amber,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
  ];

  final Map<int, Color> cropColorMap = {};

  // Getters
  List<ScheduleCrop> get cropsForSelectedLand =>
      selectedLand.value?.crops ?? [];

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    landId.value = Get.arguments?['landId'] ?? 0;
    cropId.value = Get.arguments?['cropId'] ?? 0;
    fetchLandsAndCrops();
  }

  // Methods
  Future<void> selectLand(ScheduleLand? land) async {
    selectedLand.value = land;
    selectedCrop.value = allCrop;
    await fetchLandsAndCropMap();
    selectCrop(allCrop);
  }

  void selectCrop(ScheduleCrop? crop) {
    selectedCrop.value = crop ?? allCrop;
    zoomCrop();
  }

  void changeMapType(MapType type) {
    mapType.value = type;
  }

  void updateCameraToPolygon(List<LatLng> polygon) {
    if (polygon.isEmpty) return;

    var bounds = boundsFromLatLngList(polygon);

    if (mapController == null) {
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

  Future<void> fetchLandsAndCrops() async {
    try {
      isLoading(true);
      final result = await _repository.fetchLandsAndCrops();
      lands.assignAll(result);


      if (result.isNotEmpty) {
        if (landId.value != 0) {
          selectedLand.value = result.firstWhere(
            (land) => land.id == landId.value,
          );
          await fetchLandsAndCropMap();
          
          selectCrop(allCrop);
        } else {
          selectedLand.value = result.first;
          await fetchLandsAndCropMap();

          selectCrop(allCrop);
        }
      }
    } finally {
      isLoading(false);
    }
  }



  void _assignCropColors(List<CropMapData> crops) {
    cropColorMap.clear();
    for (int i = 0; i < crops.length; i++) {
      if (crops[i].cropId != null) {
        cropColorMap[crops[i].cropId!] = cropColors[i % cropColors.length];
      }
    }
  }

  Color getLandColor(int landId) =>  Colors.green;

  Color getCropColor(int cropId) => cropColorMap[cropId] ?? Colors.orange;

  Future<void> fetchLandsAndCropsDetails(int cropId) async {
    try {
      final result = await _repository.fetcCropDetails(
        selectedLand.value!.id,
        cropId,
      );
      cropDetails.value = result;
    } finally {
      // Handle completion if needed
    }
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
          // ignore: deprecated_member_use
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
          infoWindow: InfoWindow(
            title: crop.cropName ?? "Crop",
            snippet: "Tap for details",
          ),
          onTap: () {
            cropDetailsSheet(crop);
          },
        ),
      );
    }
    return markers;
  }

  Future fetchLandsAndCropMap() async {
    if (selectedLand.value == null) return;
    
    try {
      final result = await _repository.fetchLandsAndCropMap(
        selectedLand.value!.id,
      );
      landMapDetails.value = result;

      // Assign colors to crops
      if (result.crops != null) {
        _assignCropColors(result.crops!);
      }

      // land polygon
      landpolyline.value = parseLatLngListFromString(
        result.geoMarks ?? [],
      ).toList();

      // update polygons reactively
      final polySet = <Polygon>{
        if (landpolyline.isNotEmpty)
          Polygon(
            polygonId: PolygonId("land_${selectedLand.value!.id}"),
            points: landpolyline,
            fillColor: getLandColor(selectedLand.value!.id).withAlpha(50),
            strokeColor: getLandColor(selectedLand.value!.id),
            strokeWidth: 3,
            consumeTapEvents: true,
            onTap: () {
              _showLandDetailsSheet();
            },
          ),
        if (result.crops != null)
          ...result.crops!.map((crop) {
            if (crop.geoMarks == null || crop.geoMarks!.isEmpty) {
              return Polygon(
                polygonId: PolygonId("empty_crop_${crop.cropId}"),
                points: [],
                fillColor: Colors.transparent,
                strokeColor: Colors.transparent,
                strokeWidth: 0,
              );
            }
            
            final cropPoints = crop.geoMarks!
                .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
                .toList();
            
            return Polygon(
              polygonId: PolygonId("crop_${crop.cropId}"),
              points: cropPoints,
              fillColor: getCropColor(crop.cropId!).withAlpha(120),
              strokeColor: getCropColor(crop.cropId!),
              strokeWidth: 2,
              consumeTapEvents: true,
              onTap: () => cropDetailsSheet(crop),
            );
          }),
      };
      polygons.assignAll(polySet);
      markers.assignAll(await buildCropMarkers(result.crops ?? []));
    } catch (e) {
      print("Error fetching land and crop map: $e");
    }
    return;
  }

  void _showLandDetailsSheet() {
    if (selectedLand.value == null) return;

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Land Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: getLandColor(selectedLand.value!.id),
              ),
            ),
            const SizedBox(height: 15),
            _buildDetailRow('Land Name:', selectedLand.value!.name),
            _buildDetailRow('Land ID:', selectedLand.value!.id.toString()),
            // if (landMapDetails.value?.totalArea != null)
            //   _buildDetailRow('Total Area:', '${landMapDetails.value!.totalArea} sqm'),
            if (landMapDetails.value?.crops != null)
              _buildDetailRow('Number of Crops:', landMapDetails.value!.crops!.length.toString()),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: getLandColor(selectedLand.value!.id),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );

  void zoomCrop() {
    if (landMapDetails.value?.crops == null) {
      updateCameraToPolygon(landpolyline);
      return;
    }

    final crop = landMapDetails.value!.crops!.firstWhere(
      (c) => c.cropId == selectedCrop.value?.id,
      orElse: () => CropMapData(),
    );
    if (crop.geoMarks?.isNotEmpty == true) {
      final poly = crop.geoMarks!
          .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
          .toList();
      updateCameraToPolygon(poly);
    } else {
      updateCameraToPolygon(landpolyline);
    }
  }

  Future<void> cropDetailsSheet(CropMapData crop) async {
    Get.dialog(
      const Dialog(
        child: SizedBox(
          height: 100,
          width: 100,
          child: Center(child: CircularProgressIndicator(strokeWidth: 6)),
        ),
      ),
    );

    fetchWeatherData(crop.geoMarks![0][0], crop.geoMarks![0][1]);
    await fetchLandsAndCropsDetails(crop.cropId!);
    Get.back();

    Get.bottomSheet(
      isScrollControlled: true,
      CropDetailsBottomSheet(crop: crop),
    );
  }

  Future<void> fetchWeatherData(double lat, double lon) async {
    weatherData.value = await _repository.getWeatherData(lat, lon);
  }

  // Refresh method
  Future<void> refreshData() async {
    isRefreshing(true);
    try {
      await fetchLandsAndCrops();
      if (selectedLand.value != null) {
        await fetchLandsAndCropMap();
      }
      Get.snackbar(
        'Success',
        'Data refreshed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isRefreshing(false);
    }
  }
}
