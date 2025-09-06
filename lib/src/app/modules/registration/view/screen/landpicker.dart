import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/location_picker_controller.dart';

class LocationPickerView extends GetView<LocationPickerController> {
  const LocationPickerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: controller.getCurrentLocation,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: controller.cameraPosition.value,
              onMapCreated: (GoogleMapController mapController) {},
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
            ),
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
                      // Text(
                      //   'Selected Location',
                      //   style: TextStyle(fontWeight: FontWeight.bold),
                      // ),
                      // SizedBox(height: 8),
                      // Obx(() => Text(controller.address.value)),
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
              bottom: 200,
              child: FloatingActionButton(
                onPressed: controller.getCurrentLocation,
                backgroundColor: Get.theme.primaryColor,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        );
      }),
    );
}
