import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/location_picker_controller.dart';

class LocationPickerView extends GetView<LocationPickerController> {
  const LocationPickerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(
      title: 'Select Location',
      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.my_location),
      //     onPressed: controller.getCurrentLocation,
      //   ),
      // ],
    ),
    body: Stack(
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return GoogleMap(
            // key: UniqueKey(),
            initialCameraPosition: controller.cameraPosition.value,
            onMapCreated: (GoogleMapController mapController) {
              controller.mapController = mapController;
            },
            onTap: controller.onMapTap,
            markers: controller.selectedLocation.value != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: controller.selectedLocation.value!,
                    ),
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          );
        }),
        // keep overlays (buttons, cards) outside so they don’t rebuild Map
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.confirmSelection,
                      child: const Text('Confirm Location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 150,
          child: FloatingActionButton(
            onPressed: controller.getCurrentLocation,
            backgroundColor: Get.theme.primaryColor,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    ),
  );
}
