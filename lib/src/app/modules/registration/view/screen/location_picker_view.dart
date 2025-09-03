import 'package:argiot/src/app/modules/registration/controller/land_picker_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    if (args != null && args['zoom'] != null) {
      controller.zoom.value = Get.arguments['zoom'];
    }

    controller.getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [IconButton(icon: Icon(Icons.info_outline), onPressed: () {})],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
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
                        markerId: MarkerId('select'),
                        position: controller.selectedLocation.value!,
                      ),
                    }
                  : {},
              polygons: {
                if (controller.landPolylin.isNotEmpty)
                  Polygon(
                    consumeTapEvents: false,
                    polygonId: PolygonId("test"),
                    points: controller.landPolylin,
                    fillColor: Colors.green.withAlpha(50),
                    strokeColor: Colors.green,

                    geodesic: true,
                    strokeWidth: 4,
                  ),
              },
              polylines: {
                Polyline(
                  polylineId: PolylineId("drawn_path"),
                  color: Colors.red,
                  width: 4,
                  points: controller.polylinePoints,
                ),
                if (controller.polylinePoints.isNotEmpty)
                  Polyline(
                    polylineId: PolylineId("end"),
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
              right: 20,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.confirmSelection,
                          child: Text('Confirm Location'),
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
                child: Icon(Icons.my_location),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 180,
              child: FloatingActionButton(
                heroTag: "clear_polyline",
                backgroundColor: Colors.red,
                onPressed: controller.clearPolyline,
                child: Icon(Icons.clear),
              ),
            ),
          ],
        );
      }),
    );
  }
}
