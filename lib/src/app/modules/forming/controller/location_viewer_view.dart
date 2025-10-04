import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../widgets/loading.dart';
import 'location_viewer_controller.dart';

class LocationViewerView extends GetView<LocationViewerController> {
  const LocationViewerView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: const CustomAppBar(title: 'Location Viewer', showBackButton: true),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Loading();
        }

        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    controller.latitude.value,
                    controller.longitude.value,
                  ),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('land-location'),
                    position: LatLng(
                      controller.latitude.value,
                      controller.longitude.value,
                    ),
                  ),
                },
              ),
            ),
            if (controller.address.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Approximate Address'),
                    subtitle: Text(controller.address.value),
                  ),
                ),
              ),
          ],
        );
      }),
    );

  // void _shareLocation() {
  //   // Share.share(
  //   //   'Land Location: https://www.google.com/maps?q=${controller.latitude.value},${controller.longitude.value}',
  //   // );
  // }
}
