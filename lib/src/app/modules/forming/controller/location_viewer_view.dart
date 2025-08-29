import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../near_me/views/widget/widgets.dart';
import 'location_viewer_controller.dart';

class LocationViewerView extends GetView<LocationViewerController> {
  const LocationViewerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: 
        CustomAppBar(title: 'Location Viewer', showBackButton: true),
       
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
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
                    markerId: MarkerId('land-location'),
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
                padding: EdgeInsets.all(16),
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Approximate Address'),
                    subtitle: Text(controller.address.value),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // void _shareLocation() {
  //   // Share.share(
  //   //   'Land Location: https://www.google.com/maps?q=${controller.latitude.value},${controller.longitude.value}',
  //   // );
  // }
}