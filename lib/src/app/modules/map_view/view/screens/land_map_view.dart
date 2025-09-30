import 'package:argiot/src/app/modules/map_view/controller/land_map_view_controller.dart';
import 'package:argiot/src/app/modules/map_view/view/widgets/map_float_action_button.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/task/model/schedule_crop.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';


import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../widgets/input_card_style.dart';

class LandMapView extends GetView<LandMapViewController> {
  const LandMapView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Land Details'),
    body: Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Stack(
        children: [
          GoogleMap(
            mapType: controller.mapType.value,
            initialCameraPosition: controller.cameraPosition.value,
            onMapCreated: (GoogleMapController mapController) {
              controller.mapController = mapController;
              if (controller.pendingBounds != null) {
                controller.mapController!.animateCamera(
                  CameraUpdate.newLatLngBounds(controller.pendingBounds!, 60),
                );
                controller.pendingBounds = null;
              }
            },
            markers: controller.markers,
            polygons: controller.polygons,
            onTap: (LatLng position) {
              // Handle map tap if needed
            },
          ),

          Positioned(
            top: 8,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(child: _buildLandDropdown()),
                  const SizedBox(width: 10),
                  Expanded(child: _buildCropDropdown()),
                ],
              ),
            ),
          ),

          // Refresh Button
          // Positioned(
          //   bottom: 100,
          //   right: 20,
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       controller.refreshData();
          //     },
          //     backgroundColor: Colors.white,
          //     child: const Icon(Icons.refresh, color: Colors.green),
          //   ),
          // ),
        ],
      );
    }),
    floatingActionButtonLocation: ExpandableFab.location,
    floatingActionButton: const MapFloatActionButton(),
  );

  Widget _buildLandDropdown() => Obx(
    () => InputCardStyle(
      child: DropdownButtonFormField<ScheduleLand>(
        initialValue: controller.selectedLand.value,
        items: controller.lands
            .map(
              (land) => DropdownMenuItem(value: land, child: Text(land.name)),
            )
            .toList(),
        onChanged: controller.selectLand,
        decoration: const InputDecoration(
          labelText: 'Land',
          border: InputBorder.none,
        ),
      ),
    ),
  );

  Widget _buildCropDropdown() => Obx(
    () => InputCardStyle(
      child: DropdownButtonFormField<ScheduleCrop>(
        initialValue: controller.selectedCrop.value,
        items: [
          DropdownMenuItem(value: controller.allCrop, child: const Text("All")),
          ...controller.cropsForSelectedLand.map(
            (crop) => DropdownMenuItem(value: crop, child: Text(crop.name)),
          ),
        ],
        onChanged: controller.selectCrop,
        decoration: const InputDecoration(
          labelText: 'Crop',
          border: InputBorder.none,
        ),
      ),
    ),
  );
}
