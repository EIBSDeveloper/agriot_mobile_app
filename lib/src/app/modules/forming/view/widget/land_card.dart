import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_routes.dart';
import '../../../../../utils.dart';
import '../../../subscription/package_model.dart';
import '../../model/land_model.dart';
import 'crop_card.dart';

class LandCard extends StatelessWidget {
  final Land land;
  final bool isExpanded;
  final VoidCallback onExpand;
  final VoidCallback onTap;

  const LandCard({
    super.key,
    required this.land,
    required this.isExpanded,
    required this.onExpand,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      // margin: EdgeInsets.only(bottom: 4),
      child: Card(
        elevation: 0,
        color: !isExpanded
            ? Colors.white
            : (Get.theme.colorScheme.primary.withAlpha(30)),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Left side: Name and count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                land.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  // color: TEc
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '(${land.landCropCount})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Get.theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${land.village.name} • ${land.measurementValue} ${land.measurementUnit.name}',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 40,
                          ),
                          onPressed: onExpand,
                        ),
                        // IconButton(
                        //   icon: Icon(Icons.open_in_new),
                        //   onPressed: onTap,
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (isExpanded) ...[
              Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Crops ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ...land.crops.map(
                      (crop) => InkWell(
                        onTap: () {
                          Get.toNamed(
                            '/crop-overview',
                            arguments: {'landId': land.id, 'cropId': crop.id},
                          );
                        },
                        child: CropCard(crop: crop),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            PackageUsage? package = findLimit();

                            if (package!.cropBalance > 0) {
                              Get.toNamed(Routes.addCrop, arguments: land.id);
                            } else {
                              showDefaultGetXDialog("Crop");
                            }
                          },
                          child: Text(
                            "Add  New Crop",
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
