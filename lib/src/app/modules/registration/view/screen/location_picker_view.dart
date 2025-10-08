import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/registration/controller/land_picker_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/app_images.dart';
import '../../../../widgets/loading.dart';

LatLng calculateCenter(List<LatLng> points) {
  if (points.isEmpty) {
    throw ArgumentError('Points list cannot be empty');
  }

  double sumLat = 0;
  double sumLng = 0;

  for (var point in points) {
    sumLat += point.latitude;
    sumLng += point.longitude;
  }

  return LatLng(sumLat / points.length, sumLng / points.length);
}

class LandPickerView extends StatefulWidget {
  const LandPickerView({super.key});

  @override
  State<LandPickerView> createState() => _LandPickerViewState();
}

class _LandPickerViewState extends State<LandPickerView> {
  LandPickerController controller = Get.find();
  @override
  void initState() {
    final args = Get.arguments;
    if (args != null && args['land'] != null) {
      var argument = Get.arguments['land'].toList();
      controller.landPolylin.addAll(argument);
    }
    if (args != null && args['crop'] != null) {
      controller.croppolyiline.value = Get.arguments['crop'];
    }
    if (args != null && args['priviese_crop'] != null) {
      controller.priviesCropCoordinates.value = Get.arguments['priviese_crop'];
    }
    if (args != null && args['zoom'] != null) {
      controller.zoom.value = Get.arguments['zoom'];
    }

    controller.getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'select_location'.tr,
      actions: [
        IconButton(icon: const Icon(Icons.info_outline), onPressed: infoImage),
      ],
    ),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Loading();
      }
      return Stack(
        children: [
          GoogleMap(
            initialCameraPosition: controller.cameraPosition.value,
            onMapCreated: (GoogleMapController mapController) {
              controller.mapController = mapController;
            },
            onTap: controller.onMapTap,

            markers: controller.selectedLocation.value != null
                ? {
                    Marker(
                      markerId: const MarkerId('select'),
                      position: controller.selectedLocation.value!,
                    ),
                  }
                : {},
            polygons: {
              if (controller.landPolylin.isNotEmpty)
                Polygon(
                  consumeTapEvents: false,
                  polygonId: const PolygonId("test"),
                  points: controller.landPolylin,
                  fillColor: Colors.green.withAlpha(50),
                  strokeColor: Colors.green,
                  geodesic: true,
                  strokeWidth: 4,
                ),
              if (controller.priviesCropCoordinates.isNotEmpty)
                ...controller.priviesCropCoordinates.map(
                  (polygon) => Polygon(
                    consumeTapEvents: false,
                    polygonId: const PolygonId("crop"),
                    points: polygon!,
                    fillColor: Colors.orange.withAlpha(50),
                    strokeColor: Colors.orange,
                    geodesic: true,
                    strokeWidth: 4,
                  ),
                ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("drawn_path"),
                color: Colors.red,
                width: 4,
                points: controller.polylinePoints,
              ),
              if (controller.polylinePoints.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId("end"),
                  color: Colors.grey,
                  width: 3,
                  points: [
                    controller.polylinePoints.first,
                    controller.polylinePoints.last,
                  ],
                  patterns: [PatternItem.dash(10), PatternItem.gap(10)],
                ),
            },
            myLocationEnabled: true,

            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 60,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.confirmSelection,
                        child: Text('confirm_location'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 250,
            child: FloatingActionButton(
              heroTag: "current_location",
              backgroundColor: Get.theme.primaryColor,
              onPressed: controller.getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 180,
            child: FloatingActionButton(
              heroTag: "clear_polyline",
              backgroundColor: Colors.red,
              onPressed: controller.clearPolyline,
              child: const Icon(Icons.clear),
            ),
          ),
        ],
      );
    }),
  );

  infoImage() => Get.defaultDialog(
    title: "mark_your_land_boundaries".tr,
    content: Image.asset(
      AppImages.landMark,
      width: 350,
      height: 250,
      fit: BoxFit.fill,
    ),radius : 10.0,
    actions: [
      TextButton(
        onPressed: () {
          Get.back();
        },
        child: Text("close".tr),
      ),
    ],
  );
}
