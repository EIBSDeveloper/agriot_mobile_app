import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/app_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../service/utils/utils.dart';
import '../../model/land.dart';
import 'crop_card.dart';

class LandCard extends StatelessWidget {
  final Land land;
  final bool isExpanded;
  final VoidCallback onExpand;
  final VoidCallback onTap;
  final VoidCallback refresh;

  LandCard({
    super.key,
    required this.land,
    required this.isExpanded,
    required this.onExpand,
    required this.onTap,
    required this.refresh,
  });
  final AppDataController appDeta = Get.put(AppDataController());
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    // margin: EdgeInsets.only(bottom: 4),
    child: Card(
      elevation: 0,
      color: !isExpanded
          ? Colors.white
          : (Get.theme.colorScheme.primary.withAlpha(50)),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              capitalizeFirstLetter(land.name),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                // color: TEc
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${land.landCropCount})',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Get.theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${land.measurementValue.round()} ${land.measurementUnit}',
                          style: const TextStyle(color: Colors.black),
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
                          color: Get.theme.primaryColor,
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
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Crops ',
                  //       style: TextStyle(fontWeight: FontWeight.bold),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 8),
                  if (appDeta.permission.value?.crop?.list != 0)
                    ...land.crops.map(
                      (crop) => InkWell(
                        onTap: () {
                          Get.toNamed(
                            Routes.cropOverview,
                            arguments: {'landId': land.id, 'cropId': crop.id},
                          )?.then((result) {
                            if (result ?? false) {
                              refresh.call();
                            }
                          });
                        },
                        child: CropCard(crop: crop),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async {
                          // PackageUsage? package = await findLimit();
                          // if (package!.cropBalance > 0) {
                          Get.toNamed(Routes.addCrop, arguments: land.id)?.then(
                            (result) {
                              if (result ?? false) {
                                refresh.call();
                              }
                            },
                          );
                          // } else {
                          //   showDefaultGetXDialog("Crop");
                          // }
                        },
                        child: Text(
                          "Add New Crop",
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
          const Divider(),
        ],
      ),
    ),
  );
}
