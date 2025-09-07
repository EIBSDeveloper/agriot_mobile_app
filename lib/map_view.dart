import 'dart:convert';
import 'dart:ui';

import 'package:argiot/bestschedule.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/dashboad/model/weather_data.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/modules/registration/repostrory/crop_service.dart';
import 'package:argiot/src/app/modules/task/model/model.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:argiot/src/routes/app_routes.dart';
import 'package:argiot/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LandMapViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LandMapViewRepository());
    Get.lazyPut(() => LandMapViewController());
  }
}

class LandMapViewRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.put(AppDataController());

  Future<List<ScheduleLand>> fetchLandsAndCrops() async {
    final farmerId = appDeta.userId;
    try {
      final response = await _httpService.get(
        '/land-and-crop-details/$farmerId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> landsJson = json.decode(response.body)['lands'];
        return landsJson.map((json) => ScheduleLand.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lands and crops');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<CropDetails> fetcCropDetails(int land, int crop) async {
    final farmerId = appDeta.userId;
    try {
      final response = await _httpService.get(
        '/crop_summary/$farmerId/$land/$crop',
      );

      if (response.statusCode == 200) {
        return CropDetails.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load lands and crops');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<WeatherData> getWeatherData(double lat, double lon) async {
    var weatherBaseUrllatlatlonlonappidweatherApiKey =
        '${appDeta.weatherBaseUrl}?lat=$lat&lon=$lon&appid=${appDeta.weatherApiKey}';
    final response = await _httpService.getRaw(
      weatherBaseUrllatlatlonlonappidweatherApiKey,
    );
    return WeatherData.fromJson(json.decode(response.body));
  }

  Future<LandMapData> fetchLandsAndCropMap(int landId) async {
    final farmerId = appDeta.userId;
    try {
      final response = await _httpService.get(
        '/lands/geo-marks/$farmerId/$landId',
      );

      if (response.statusCode == 200) {
        var decode = json.decode(response.body)[0];
        var list = LandMapData.fromJson(decode);
        return list;
      } else {
        throw Exception('Failed to load lands and crops');
      }
    } catch (e) {
      rethrow;
    }
  }
}

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
  LatLngBounds? _pendingBounds;
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

    var bounds = _boundsFromLatLngList(polygon);

    if (mapController == null) {
      // ✅ Save it until map is ready
      _pendingBounds = bounds;
      return;
    }

    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
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
          final bytes = await _getBytesFromUrl(crop.cropImage!, width: 120);
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

class LandMapView extends StatefulWidget {
  const LandMapView({super.key});

  @override
  State<LandMapView> createState() => _LandMapViewState();
}

class _LandMapViewState extends State<LandMapView> {
  LandMapViewController controller = Get.find();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Land Details'),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Stack(
        children: [
          Obx(() {
            final cropMarkersFuture =
                controller.landMapDetails.value?.crops != null
                ? controller.buildCropMarkers(
                    controller.landMapDetails.value!.crops!,
                  )
                : Future.value(<Marker>{});

            return FutureBuilder<Set<Marker>>(
              future: cropMarkersFuture,
              builder: (context, snapshot) => Obx(
                () => GoogleMap(
                  mapType: controller.mapType.value, // reactive
                  initialCameraPosition: controller.cameraPosition.value,
                  onMapCreated: (GoogleMapController mapController) {
                    controller.mapController = mapController;
                    if (controller._pendingBounds != null) {
                      controller.mapController!.animateCamera(
                        CameraUpdate.newLatLngBounds(
                          controller._pendingBounds!,
                          60,
                        ),
                      );
                      controller._pendingBounds = null;
                    }
                  },
                  polygons: {
                    if (controller.landpolyline.isNotEmpty)
                      Polygon(
                        polygonId: const PolygonId("land"),
                        points: controller.landpolyline,
                        fillColor: Colors.green.withOpacity(0.3),
                        strokeColor: Colors.green,
                        strokeWidth: 3,
                      ),
                    if (controller.landMapDetails.value?.crops != null)
                      ...controller.landMapDetails.value!.crops!.map((crop) {
                        final cropPoints = crop.geoMarks!
                            .map(
                              (e) => LatLng(e[0].toDouble(), e[1].toDouble()),
                            )
                            .toList();
                        return Polygon(
                          polygonId: PolygonId("crop_${crop.cropId}"),
                          points: cropPoints,
                          fillColor: Colors.orange.withOpacity(0.3),
                          strokeColor: Colors.orange,
                          strokeWidth: 2,
                          consumeTapEvents: true,
                          onTap: () => cropDetails(crop),
                        );
                      }),
                  },
                  markers: snapshot.data ?? {},
                ),
              ),
            );
          }),

          Positioned(
            top: 8,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Container(
                        decoration: AppStyle.decoration.copyWith(
                          color: const Color.fromARGB(137, 221, 234, 234),
                          boxShadow: const [],
                        ),

                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: DropdownButtonFormField<ScheduleLand>(
                          value: controller.selectedLand.value,

                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: controller.lands
                              .map(
                                (ScheduleLand land) =>
                                    DropdownMenuItem<ScheduleLand>(
                                      value: land,
                                      child: Text(land.name),
                                    ),
                              )
                              .toList(),
                          onChanged: (ScheduleLand? land) {
                            controller.selectLand(land);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Land',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      if (controller.selectedLand.value == null) {
                        return Container(
                          decoration: AppStyle.decoration.copyWith(
                            color: const Color.fromARGB(137, 221, 234, 234),
                            boxShadow: const [],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: DropdownButtonFormField<ScheduleCrop>(
                            value: controller.selectedCrop.value,

                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: [
                              DropdownMenuItem<ScheduleCrop>(
                                value: ScheduleCrop(id: 0, name: "All"),
                                child: const Text("All"),
                              ),
                              ...controller.cropsForSelectedLand.map(
                                (ScheduleCrop crop) =>
                                    DropdownMenuItem<ScheduleCrop>(
                                      value: crop,
                                      child: Text(crop.name),
                                    ),
                              ),
                            ],
                            onChanged: (ScheduleCrop? crop) {
                              controller.selectCrop(crop);
                            },
                            decoration: const InputDecoration(
                              hintText: 'Crop',
                              border: InputBorder.none,
                            ),
                          ),
                        );
                      }

                      return Container(
                        decoration: AppStyle.decoration.copyWith(
                          color: const Color.fromARGB(137, 221, 234, 234),
                          boxShadow: const [],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: DropdownButtonFormField<ScheduleCrop>(
                          value: controller
                              .selectedCrop
                              .value, // will be either All or a real crop
                          items: [
                            DropdownMenuItem<ScheduleCrop>(
                              value: controller.allCrop, // ✅ same reference
                              child: const Text("All"),
                            ),
                            ...controller.cropsForSelectedLand.map(
                              (ScheduleCrop crop) =>
                                  DropdownMenuItem<ScheduleCrop>(
                                    value: crop,
                                    child: Text(crop.name),
                                  ),
                            ),
                          ],

                          icon: const Icon(Icons.keyboard_arrow_down),
                          onChanged: (ScheduleCrop? crop) {
                            controller.selectCrop(crop);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Crop',
                            border: InputBorder.none,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          // Positioned(
          //   bottom: 8,

          //   left: 8,
          //   child:  ),
        ],
      );
    }),
    floatingActionButtonLocation: ExpandableFab.location,
    floatingActionButton: ExpandableFab(
      distance: 80,

      type: ExpandableFabType.fan,
      pos: ExpandableFabPos.left,
      children: [
        FloatingActionButton.small(
          heroTag: "hybrid",
          onPressed: () => controller.changeMapType(MapType.hybrid),
          child: const Icon(Icons.layers),
        ),
        FloatingActionButton.small(
          heroTag: "normal",
          onPressed: () => controller.changeMapType(MapType.normal),
          child: const Icon(Icons.map),
        ),
        FloatingActionButton.small(
          heroTag: "satellite",
          onPressed: () => controller.changeMapType(MapType.satellite),
          child: const Icon(Icons.satellite_alt),
        ),

        // FloatingActionButton.small(
        //   heroTag: "terrain",
        //   onPressed: () => controller.changeMapType(MapType.terrain),
        //   child: const Icon(Icons.terrain),
        // ),
      ],
    ),
  );

  void cropDetails(CropMapData crop) {
    Get.dialog(
      const Dialog(
        child: SizedBox(
          height: 100,
          width: 100,
          child: Center(child: CircularProgressIndicator(strokeWidth: 6)),
        ),
      ),
    );

    controller.fetchLandsAndCropsDetails(crop.cropId);
    Get.back();
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        // height: 300,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleText(crop.cropName ?? "Crop"),
            const SizedBox(height: 8),
            Row(
              children: [
                if (crop.cropImage != null)
                  Image.network(crop.cropImage!, height: 80, width: 80),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type: ${crop.cropType ?? ""}"),
                    Text('Expense:  ₹${controller.cropDetails.value!.expense}'),
                    Text('Sales:  ₹${controller.cropDetails.value!.sales}'),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${kelvinToCelsius(controller.weatherData.value!.temperature).toStringAsFixed(1)}°C|°F'
                        .tr,
                    style: TextStyle(
                      fontSize: 20,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text("/"),
                const SizedBox(width: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(controller.weatherData.value!.condition.tr),
                ),
                const SizedBox(width: 4),
                const Text("/"),
                const SizedBox(width: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${"humidity_percentage".tr}${controller.weatherData.value!.humidity.toString()}",
                  ),
                ),
              ],
            ),
            const TitleText("Today task"),
            Obx(
              () => Column(
                children: [
                  ...controller.cropDetails.value!.tasks.map(
                    (task) => _buildTaskCard(
                      Task(
                        id: task.id,
                        cropType: task.activityType,
                        cropImage: "cropImage",
                        description: task.description,
                        status: task.scheduleStatusName,
                      ),
                      crop.cropId,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task tas, id) {
    Task task = tas;
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.taskDetail, arguments: {'taskId': task.id})?.then((
          result,
        ) {
          controller.fetchLandsAndCropsDetails(id);
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: Colors.grey.withAlpha(30), //rgb(226,237,201)
        elevation: 0,
        child: ListTile(
          title: Text(task.cropType),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.status ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IconButton(
              //   icon: Icon(Icons.edit, color: Get.theme.primaryColor),
              //   onPressed: () => _showEditTaskBottomSheet(task.id),
              // ),
              // IconButton(
              //   icon: Icon(Icons.delete, color: Get.theme.primaryColor),
              //   onPressed: () => controller.deleteTask(task.id),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class LandMapData {
  final int? landId;
  final String? landName;
  final int? farmerId;
  final List<List<double>>? geoMarks;
  final List<CropMapData>? crops;

  LandMapData({
    this.landId,
    this.landName,
    this.farmerId,
    this.geoMarks,
    this.crops,
  });

  factory LandMapData.fromJson(Map<String, dynamic> json) => LandMapData(
    landId: json["land_id"],
    landName: json["land_name"],
    farmerId: json["farmer_id"],
    geoMarks: json["geo_marks"] == null
        ? []
        : (json["geo_marks"] as List)
              .where((point) => point["lat"] != null && point["lng"] != null)
              .map<List<double>>(
                (point) => [point["lat"].toDouble(), point["lng"].toDouble()],
              )
              .toList(),

    crops: json["crops"] == null
        ? []
        : List<CropMapData>.from(
            json["crops"]!.map((x) => CropMapData.fromJson(x)),
          ),
  );
}

class CropMapData {
  final int? cropId;
  final String? cropType;
  final String? cropName;
  final List<List<double>>? geoMarks;
  final String? cropImage;

  CropMapData({
    this.cropId,
    this.cropType,
    this.cropName,
    this.geoMarks,
    this.cropImage,
  });

  factory CropMapData.fromJson(Map<String, dynamic> json) => CropMapData(
    cropId: json["crop_id"],
    cropType: json["crop_type"],
    cropName: json["crop_name"],
    geoMarks: json["geo_marks"] == null
        ? []
        : (json["geo_marks"] as List)
              .where((point) => point["lat"] != null && point["lng"] != null)
              .map<List<double>>(
                (point) => [point["lat"].toDouble(), point["lng"].toDouble()],
              )
              .toList(),
    cropImage: json["crop_image"],
  );
}

Future<Uint8List> _getBytesFromUrl(String url, {int width = 100}) async {
  final http.Response response = await http.get(Uri.parse(url));
  final Uint8List bytes = response.bodyBytes;
  final codec = await instantiateImageCodec(bytes, targetWidth: width);
  final frameInfo = await codec.getNextFrame();
  final byteData = await frameInfo.image.toByteData(
    format: ImageByteFormat.png,
  );
  return byteData!.buffer.asUint8List();
}

class CropDetails {
  final int id;
  final String crop;
  final String type;
  final String soilType;
  final DateTime plantationDate;
  final String harvestingType;
  final double measurementValue;
  final String measurementUnit;
  final double expense;
  final double sales;
  final List<CropTask> tasks;

  CropDetails({
    required this.id,
    required this.crop,
    required this.type,
    required this.soilType,
    required this.plantationDate,
    required this.harvestingType,
    required this.measurementValue,
    required this.measurementUnit,
    required this.expense,
    required this.sales,
    required this.tasks,
  });

  factory CropDetails.fromJson(Map<String, dynamic> json) => CropDetails(
    id: json['id'] ?? 0,
    crop: json['crop'] ?? '',
    type: json['type'] ?? '',
    soilType: json['soil_type'] ?? '',
    plantationDate: DateTime.parse(json['plantation_date'] ?? '2025-01-01'),
    harvestingType: json['harvesting_type'] ?? '',
    measurementValue: (json['measurement_value'] ?? 0).toDouble(),
    measurementUnit: json['measurement_unit'] ?? '',
    expense: (json['expense'] ?? 0).toDouble(),
    sales: (json['sales'] ?? 0).toDouble(),
    tasks: (json['task'] as List<dynamic>? ?? [])
        .map((taskJson) => CropTask.fromJson(taskJson))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'crop': crop,
    'type': type,
    'soil_type': soilType,
    'plantation_date': plantationDate.toIso8601String().split('T')[0],
    'harvesting_type': harvestingType,
    'measurement_value': measurementValue,
    'measurement_unit': measurementUnit,
    'expense': expense,
    'sales': sales,
    'task': tasks.map((task) => task.toJson()).toList(),
  };
}

class CropTask {
  final int id;
  final String activityType;
  final String description;
  final int scheduleStatus;
  final String scheduleStatusName;

  CropTask({
    required this.id,
    required this.activityType,
    required this.description,
    required this.scheduleStatus,
    required this.scheduleStatusName,
  });

  factory CropTask.fromJson(Map<String, dynamic> json) => CropTask(
    id: json['id'] ?? 0,
    activityType: json['activity_type'] ?? '',
    description: json['description'] ?? '',
    scheduleStatus: json['schedule_status'] ?? 0,
    scheduleStatusName: json['schedule_status_name'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'activity_type': activityType,
    'description': description,
    'schedule_status': scheduleStatus,
    'schedule_status_name': scheduleStatusName,
  };
}
