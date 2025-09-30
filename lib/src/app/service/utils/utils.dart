import 'dart:ui';

import 'package:argiot/src/app/modules/subscription/model/package_usage.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/app_controller.dart';
import '../../controller/user_limit.dart';
import '../../modules/guideline/model/guideline.dart';
import '../../routes/app_routes.dart';
import 'enums.dart';

AppDataController appData = Get.find();

UserLimitController limitController = Get.put(UserLimitController());

double kelvinToCelsius(final double kelvin) => kelvin - 273.15;

String generateGoogleMapsUrl(double latitude, double longitude) =>
    "https://www.google.com/maps/place/Madurai,+Tamil+Nadu/@$latitude,$longitude";

String capitalizeFirstLetter(final String input) =>
    input.isEmpty ? input : input[0].toUpperCase() + input.substring(1);

String? getYoutubeThumbnailUrl(
  String? videoId, {
  String quality = 'hqdefault',
}) =>
    videoId == null ? null : 'https://img.youtube.com/vi/$videoId/$quality.jpg';

extension IterableUtils<E> on Iterable<E> {
  Iterable<T> whereMap<T>(T? Function(E e) transform) sync* {
    for (final e in this) {
      final result = transform(e);
      if (result != null) yield result;
    }
  }
}

Future<void> openUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

Future<void> makePhoneCall(final String phoneNumber) async {
  final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $uri';
  }
}

Future<PackageUsage?> findLimit() async {
  await limitController.loadUsage();
  return limitController.packageUsage.value;
}

String getType(int id) {
  if (id == 6) {
    return 'fuel';
  } else if (id == 1) {
    return 'vehicle';
  } else if (id == 2) {
    return 'machinery';
  } else if (id == 3) {
    return 'tools';
  } else if (id == 4) {
    return 'Pesticides';
  } else if (id == 5) {
    return 'fertilizers';
  } else if (id == 7) {
    return 'seeds';
  }
  return 'fuel';
}

int getInventoryTypeId(InventoryTypes typeName) {
  switch (typeName) {
    case InventoryTypes.fuel:
      return 6;
    case InventoryTypes.vehicle:
      return 1;
    case InventoryTypes.machinery:
      return 2;
    case InventoryTypes.tools:
      return 3;
    case InventoryTypes.pesticides:
      return 4;
    case InventoryTypes.fertilizer:
      return 5;
    case InventoryTypes.seeds:
      return 7;
  }
}

Future<Uint8List> getBytesFromUrl(String url, {int width = 100}) async {
  final http.Response response = await http.get(Uri.parse(url));
  final Uint8List bytes = response.bodyBytes;
  final codec = await instantiateImageCodec(bytes, targetWidth: width);
  final frameInfo = await codec.getNextFrame();
  final byteData = await frameInfo.image.toByteData(
    format: ImageByteFormat.png,
  );
  return byteData!.buffer.asUint8List();
}

String getMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

void handleGuidelineTap(Guideline guideline) {
  if (guideline.mediaType == 'video' && guideline.videoUrl != null) {
    openUrl(Uri.parse(guideline.videoUrl!)); // Open video player
  } else if (guideline.mediaType == 'document' && guideline.document != null) {
    Get.toNamed(
      Routes.docViewer,
      arguments: "${appData.imageBaseUrl.value}${guideline.document}",
    ); // Open document viewer
  } else {
    showError('Unable to open guideline content');
  }
}

int getDocTypeId(DocTypes type) {
  if (type == DocTypes.land) {
    return 0;
  } else if (type == DocTypes.expense) {
    return 1;
  } else if (type == DocTypes.sales) {
    return 2;
  } else if (type == DocTypes.inventory) {
    return 3;
  } else if (type == DocTypes.payouts) {
    return 4;
  }
  return 0;
}

Color getTaskColors(TaskTypes task) {
  switch (task) {
    case TaskTypes.completed:
      return const Color(0xFF4CAF50);
    case TaskTypes.waiting:
      return const Color(0xFFFFC107);
    case TaskTypes.pending:
      return const Color(0xFF2196F3);
    case TaskTypes.inProgress:
      return const Color(0xFF03A9F4);
    case TaskTypes.cancelled:
      return const Color(0xFFF44336);
    default:
      return const Color(0xFF9E9E9E);
  }
}

TaskTypes getTaskStatus(int task) {
  switch (task) {
    case 1:
      return TaskTypes.waiting;
    case 2:
      return TaskTypes.completed;
    case 3:
      return TaskTypes.inProgress;
    case 4:
      return TaskTypes.pending;
    case 5:
      return TaskTypes.cancelled;
    default:
      return TaskTypes.all;
  }
}

DocTypes getDocumentTypes(int task) {
  switch (task) {
    case 1:
      return DocTypes.expense;
    case 2:
      return DocTypes.sales;
    case 3:
      return DocTypes.inventory;
    case 4:
      return DocTypes.payouts;
    default:
      return DocTypes.land;
  }
}

int getTaskId(TaskTypes task) {
  switch (task) {
    case TaskTypes.waiting:
      return 1;
    case TaskTypes.completed:
      return 2;
    case TaskTypes.inProgress:
      return 3;
    case TaskTypes.pending:
      return 4;
    case TaskTypes.cancelled:
      return 5;
    default:
      return 0;
  }
}

String getTaskName(TaskTypes task) {
  switch (task) {
    case TaskTypes.waiting:
      return "Waiting";
    case TaskTypes.completed:
      return "Completed";
    case TaskTypes.inProgress:
      return "In Progress";
    case TaskTypes.pending:
      return "Pending";
    case TaskTypes.cancelled:
      return "Cancelled";
    default:
      return "All";
  }
}


extension RoleTypeExtension on RoleType {
  String get name {
    switch (this) {
      case RoleType.employee:
        return 'Employee';
      case RoleType.subAdmin:
        return 'Sub Admin';
      case RoleType.manager:
        return 'Manager';
    }
  }

  int get id {
    switch (this) {
      case RoleType.employee:
        return 1;
      case RoleType.subAdmin:
        return 2;
      case RoleType.manager:
        return 3;
    }
  }
}


extension GenderTypeExtension on GenderType {
  String get name {
    switch (this) {
      case GenderType.male:
        return 'Male';
      case GenderType.female:
        return 'Female';
      case GenderType.transgender:
        return 'TransGender';
    }
  }

  int get id {
    switch (this) {
      case GenderType.male:
        return 1;
      case GenderType.female:
        return 2;
      case GenderType.transgender:
        return 3;
    }
  }
}


/// Calculate polygon area in square feet from LatLng points
double calculatePolygonAreaSqFt(List<LatLng> points) {
  if (points.length < 3) return 0.0;

  const earthRadiusMeters = 6371000.0; // Earth radius in meters
  double area = 0.0;

  for (int i = 0; i < points.length; i++) {
    LatLng p1 = points[i];
    LatLng p2 = points[(i + 1) % points.length];

    double lat1 = p1.latitude * pi / 180;
    double lon1 = p1.longitude * pi / 180;
    double lat2 = p2.latitude * pi / 180;
    double lon2 = p2.longitude * pi / 180;

    area += (lon2 - lon1) * (2 + sin(lat1) + sin(lat2));
  }

  area = area * earthRadiusMeters * earthRadiusMeters / 2.0;

  // Absolute value (in case polygon points are reversed)
  double areaMeters = area.abs();

  // Convert meters² → feet²  (1 m² = 10.7639 ft²)
  return areaMeters * 10.7639;
}
// void showLandArea() {
//   double areaSqFt = calculatePolygonAreaSqFt(landpolyline);
//   print("Land Area: ${areaSqFt.toStringAsFixed(2)} sq.ft");
// }

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// // ======================= VIEW =======================
// class LandMapView extends GetView<LandMapViewController> {
//   const LandMapView({super.key});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: const CustomAppBar(title: 'Land Details'),
//         body: Obx(() {
//           if (controller.isLoading.value) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return Stack(
//             children: [
//               GoogleMap(
//                 mapType: controller.mapType.value,
//                 initialCameraPosition: controller.cameraPosition.value,
//                 onMapCreated: (GoogleMapController mapController) {
//                   controller.mapController = mapController;
//                   if (controller.pendingBounds != null) {
//                     controller.mapController!.animateCamera(
//                       CameraUpdate.newLatLngBounds(
//                           controller.pendingBounds!, 60),
//                     );
//                     controller.pendingBounds = null;
//                   }
//                 },
//                 markers: controller.markers,
//                 polygons: controller.polygons,
//               ),

//               // Dropdowns
//               Positioned(
//                 top: 8,
//                 right: 0,
//                 left: 0,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     children: [
//                       Expanded(child: _buildLandDropdown()),
//                       const SizedBox(width: 10),
//                       Expanded(child: _buildCropDropdown()),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }),

//         // Floating refresh button
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             await controller.fetchLandsAndCrops(); // Refresh
//           },
//           child: const Icon(Icons.refresh),
//         ),
//       );

//   Widget _buildLandDropdown() => Obx(
//         () => InputCardStyle(
//           child: DropdownButtonFormField<ScheduleLand>(
//             value: controller.selectedLand.value,
//             items: controller.lands
//                 .map((land) =>
//                     DropdownMenuItem(value: land, child: Text(land.name)))
//                 .toList(),
//             onChanged: controller.selectLand,
//             decoration: const InputDecoration(
//               labelText: 'Land',
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       );

//   Widget _buildCropDropdown() => Obx(
//         () => InputCardStyle(
//           child: DropdownButtonFormField<ScheduleCrop>(
//             value: controller.selectedCrop.value,
//             items: [
//               DropdownMenuItem(
//                   value: controller.allCrop, child: const Text("All")),
//               ...controller.cropsForSelectedLand.map(
//                 (crop) =>
//                     DropdownMenuItem(value: crop, child: Text(crop.name)),
//               ),
//             ],
//             onChanged: controller.selectCrop,
//             decoration: const InputDecoration(
//               labelText: 'Crop',
//               border: InputBorder.none,
//             ),
//           ),
//         ),
//       );
// }

// // ======================= CONTROLLER =======================
// class LandMapViewController extends GetxController {
//   final LandMapViewRepository _repository = LandMapViewRepository();
//   final AppDataController appDataController = Get.find();
//   final ScheduleCrop allCrop = ScheduleCrop(id: 0, name: "All");

//   RxBool isLoading = true.obs;
//   RxList<ScheduleLand> lands = <ScheduleLand>[].obs;
//   RxList<LatLng> landpolyline = <LatLng>[].obs;
//   Rxn<ScheduleLand> selectedLand = Rxn<ScheduleLand>();
//   Rxn<ScheduleCrop> selectedCrop = Rxn<ScheduleCrop>();
//   Rx<MapType> mapType = MapType.normal.obs;
//   Rx<CameraPosition> cameraPosition = const CameraPosition(
//     target: LatLng(12.9716, 77.5946),
//     zoom: 14,
//   ).obs;

//   final Rx<CropDetails?> cropDetails = Rx<CropDetails?>(null);
//   final Rx<WeatherData?> weatherData = Rx<WeatherData?>(null);
//   Rx<LandMapData?> landMapDetails = Rx<LandMapData?>(null);
//   final RxInt landId = 0.obs;
//   final RxInt cropId = 0.obs;

//   GoogleMapController? mapController;
//   LatLngBounds? pendingBounds;
//   final polygons = <Polygon>{}.obs;
//   final markers = <Marker>{}.obs;

//   List<ScheduleCrop> get cropsForSelectedLand =>
//       selectedLand.value?.crops ?? [];

//   @override
//   void onInit() {
//     super.onInit();
//     landId.value = Get.arguments?['landId'] ?? 0;
//     cropId.value = Get.arguments?['cropId'] ?? 0;
//     fetchLandsAndCrops();
//   }

//   Future<void> selectLand(ScheduleLand? land) async {
//     selectedLand.value = land;
//     selectedCrop.value = allCrop;
//     await fetchLandsAndCropMap();
//     selectCrop(allCrop);
//   }

//   void selectCrop(ScheduleCrop? crop) {
//     selectedCrop.value = crop ?? allCrop;
//     zoomCrop();
//   }

//   void changeMapType(MapType type) {
//     mapType.value = type;
//   }

//   void updateCameraToPolygon(List<LatLng> polygon) {
//     if (polygon.isEmpty) return;
//     var bounds = boundsFromLatLngList(polygon);
//     if (mapController == null) {
//       pendingBounds = bounds;
//       return;
//     }
//     mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
//   }

//   LatLngBounds boundsFromLatLngList(List<LatLng> list) {
//     double x0 = list.first.latitude, x1 = list.first.latitude;
//     double y0 = list.first.longitude, y1 = list.first.longitude;
//     for (LatLng latLng in list) {
//       if (latLng.latitude > x1) x1 = latLng.latitude;
//       if (latLng.latitude < x0) x0 = latLng.latitude;
//       if (latLng.longitude > y1) y1 = latLng.longitude;
//       if (latLng.longitude < y0) y0 = latLng.longitude;
//     }
//     return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
//   }

//   Future<void> fetchLandsAndCrops() async {
//     try {
//       isLoading(true);
//       final result = await _repository.fetchLandsAndCrops();
//       lands.assignAll(result);

//       if (result.isNotEmpty) {
//         if (landId.value != 0) {
//           selectedLand.value =
//               result.firstWhere((land) => land.id == landId.value);
//         } else {
//           selectedLand.value = result.first;
//         }
//         await fetchLandsAndCropMap();
//         selectCrop(allCrop);
//       }
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<void> fetchLandsAndCropsDetails(int cropId) async {
//     final result =
//         await _repository.fetcCropDetails(selectedLand.value!.id, cropId);
//     cropDetails.value = result;
//   }

//   Future<Set<Marker>> buildCropMarkers(List<CropMapData> crops) async {
//     final markers = <Marker>{};

//     for (final crop in crops) {
//       if (crop.geoMarks == null || crop.geoMarks!.isEmpty) continue;

//       final cropPoints = crop.geoMarks!
//           .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
//           .toList();

//       final center = LatLng(
//         cropPoints.map((e) => e.latitude).reduce((a, b) => a + b) /
//             cropPoints.length,
//         cropPoints.map((e) => e.longitude).reduce((a, b) => a + b) /
//             cropPoints.length,
//       );

//       markers.add(
//         Marker(
//           markerId: MarkerId("crop_${crop.cropId}"),
//           position: center,
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueGreen,
//           ),
//           infoWindow: InfoWindow(title: crop.cropName ?? "Crop"),
//         ),
//       );
//     }
//     return markers;
//   }

//   Future fetchLandsAndCropMap() async {
//     if (selectedLand.value == null) return;
//     final result =
//         await _repository.fetchLandsAndCropMap(selectedLand.value!.id);
//     landMapDetails.value = result;

//     landpolyline.value =
//         parseLatLngListFromString(result.geoMarks ?? []).toList();

//     final polySet = <Polygon>{
//       if (landpolyline.isNotEmpty)
//         Polygon(
//           polygonId: const PolygonId("land"),
//           points: landpolyline,
//           fillColor: Colors.blue.withAlpha(120),
//           strokeColor: Colors.blue,
//           strokeWidth: 3,
//           consumeTapEvents: true,
//           onTap: () => landDetailsSheet(result),
//         ),
//       if (result.crops != null)
//         ...result.crops!.map((crop) {
//           final cropPoints = crop.geoMarks!
//               .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
//               .toList();

//           // random color for each crop
//           final random = Random();
//           final color = Color.fromARGB(
//             150,
//             random.nextInt(256),
//             random.nextInt(256),
//             random.nextInt(256),
//           );

//           return Polygon(
//             polygonId: PolygonId("crop_${crop.cropId}"),
//             points: cropPoints,
//             fillColor: color,
//             strokeColor: color.withOpacity(0.9),
//             strokeWidth: 2,
//             consumeTapEvents: true,
//             onTap: () => cropDetailsSheet(crop),
//           );
//         }),
//     };

//     polygons.assignAll(polySet);
//     markers.assignAll(await buildCropMarkers(result.crops ?? []));
//   }

//   void zoomCrop() {
//     final crop = landMapDetails.value!.crops?.firstWhere(
//       (c) => c.cropId == selectedCrop.value?.id,
//       orElse: () => CropMapData(),
//     );
//     if (crop != null && crop.geoMarks?.isNotEmpty == true) {
//       final poly = crop.geoMarks!
//           .map((e) => LatLng(e[0].toDouble(), e[1].toDouble()))
//           .toList();
//       updateCameraToPolygon(poly);
//     } else {
//       updateCameraToPolygon(landpolyline);
//     }
//   }

//   Future<void> cropDetailsSheet(CropMapData crop) async {
//     Get.dialog(
//       const Dialog(
//         child: SizedBox(
//           height: 100,
//           width: 100,
//           child: Center(child: CircularProgressIndicator(strokeWidth: 6)),
//         ),
//       ),
//     );

//     fetchWeatherData(crop.geoMarks![0][0], crop.geoMarks![0][1]);
//     await fetchLandsAndCropsDetails(crop.cropId!);
//     Get.back();

//     Get.bottomSheet(
//       isScrollControlled: true,
//       CropDetailsBottomSheet(crop: crop),
//     );
//   }

//   Future<void> landDetailsSheet(LandMapData land) async {
//     Get.bottomSheet(
//       isScrollControlled: true,
//       LandDetailsBottomSheet(land: land),
//     );
//   }

//   Future<void> fetchWeatherData(double lat, double lon) async {
//     weatherData.value = await _repository.getWeatherData(lat, lon);
//   }
// }

// // ======================= LAND DETAILS BOTTOM SHEET =======================
// class LandDetailsBottomSheet extends StatelessWidget {
//   final LandMapData land;
//   const LandDetailsBottomSheet({super.key, required this.land});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text("Land: ${land.landName ?? 'Unknown'}",
//               style:
//                   const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text("Area: ${land.area ?? 'N/A'}"),
//           Text("Soil Type: ${land.soilType ?? 'N/A'}"),
//           const SizedBox(height: 12),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             child: const Text("Close"),
//           ),
//         ],
//       ),
//     );
//   }
// }
