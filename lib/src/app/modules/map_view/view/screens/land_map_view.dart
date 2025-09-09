import 'package:argiot/src/app/modules/map_view/model/crop_map_data.dart';
import 'package:argiot/src/app/modules/map_view/controller/land_map_view_controller.dart';
import 'package:argiot/src/app/modules/task/model/schedule_crop.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';

import 'package:argiot/src/app/modules/task/model/task.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
                    if (controller.pendingBounds != null) {
                      controller.mapController!.animateCamera(
                        CameraUpdate.newLatLngBounds(
                          controller.pendingBounds!,
                          60,
                        ),
                      );
                      controller.pendingBounds = null;
                    }
                  },
                  polygons: {
                    if (controller.landpolyline.isNotEmpty)
                      Polygon(
                        polygonId: const PolygonId("land"),
                        points: controller.landpolyline,
                        fillColor: Colors.green.withAlpha(150),
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
                          fillColor: Colors.orange.withAlpha(150),
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
                          initialValue: controller.selectedLand.value,

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
                            initialValue: controller.selectedCrop.value,

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
                          initialValue: controller
                              .selectedCrop
                              .value, 
                          items: [
                            DropdownMenuItem<ScheduleCrop>(
                              value: controller.allCrop, 
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

