import 'package:argiot/src/app/modules/map_view/controller/land_map_view_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapFloatActionButton extends GetView<LandMapViewController> {
  const MapFloatActionButton({super.key});

  @override
  Widget build(BuildContext context) => ExpandableFab(
    distance: 80,

    type: ExpandableFabType.fan,
    pos: ExpandableFabPos.left,
    openButtonBuilder: FloatingActionButtonBuilder(
      size: 56.0,
      builder: (context, onPressed, progress) => FloatingActionButton(
        heroTag: null,
        elevation: 0,
        backgroundColor: Colors.white,
        onPressed: onPressed,
        child: const Icon(Icons.menu, color: Colors.black),
      ),
    ),

    closeButtonBuilder: FloatingActionButtonBuilder(
      size: 56.0,
      builder: (context, onPressed, progress) => FloatingActionButton(
        heroTag: null,
        backgroundColor: Colors.white,
        onPressed: onPressed,
        child: Icon(Icons.close, color: Get.theme.primaryColor),
      ),
    ),

    children: [
      FloatingActionButton.small(
        heroTag: null,
        backgroundColor: Get.theme.primaryColor.withAlpha(150),
        elevation: 0,
        onPressed: () => controller.changeMapType(MapType.hybrid),
        child: const Icon(Icons.layers),
      ),
      FloatingActionButton.small(
        heroTag: null,
        backgroundColor: Get.theme.primaryColor.withAlpha(150),
        elevation: 0,
        onPressed: () => controller.changeMapType(MapType.normal),
        child: const Icon(Icons.map),
      ),
      FloatingActionButton.small(
        heroTag: null,
        backgroundColor: Get.theme.primaryColor.withAlpha(150),
        elevation: 0,
        onPressed: () => controller.changeMapType(MapType.satellite),
        child: const Icon(Icons.satellite_alt),
      ),
    ],
  );
}

