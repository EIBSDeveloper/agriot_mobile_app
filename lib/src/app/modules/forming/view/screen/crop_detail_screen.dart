import 'package:argiot/src/app/modules/forming/controller/crop_details_controller.dart';
import 'package:argiot/src/app/modules/forming/view/screen/crop_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../routes/app_routes.dart';
import '../../../near_me/views/widget/widgets.dart';

//////
// lib/modules/crop/views/crop_detail_screen.dart
class CropDetailScreen extends StatefulWidget {
  const CropDetailScreen({super.key});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  final CropDetailsController controller = Get.find();

  final int landId = Get.arguments['landId'];
  final int cropId = Get.arguments['cropId'];

  @override
  void initState() {
    super.initState();
    controller.fetchCropDetails(landId, cropId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Crop Details ',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              controller.deleteCrop(controller.details.value!.id!);
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailsLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.details.value == null) {
          return Center(child: Text('No crop details available'));
        }

        final crop = controller.details.value;
        return SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop Info Section
              _buildCropInfoSection(crop),
              SizedBox(height: 10),
              // Crop Details
              _buildCropDetailsSection(crop),
              SizedBox(height: 10),
              // Survey Details
              _buildSurveyDetailsSection(crop),
              SizedBox(height: 10),
              // Location
              // _buildLocationSection(crop),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCropInfoSection(MyCropDetails? details) {
    return Stack(
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,

                  backgroundImage: NetworkImage(details!.imageUrl!),
                  child: details.imageUrl!.isEmpty
                      ? Icon(Icons.agriculture, size: 30)
                      : null,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${details.crop!.name} (Day - ${controller.getDaysSincePlantation(details.plantationDate)})',
                      style: Get.textTheme.titleLarge,
                    ),
                    Text(details.land!.name!),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Get.toNamed(
              Routes.addCrop,
              arguments: {'landId': landId, 'cropId': cropId},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCropDetailsSection(MyCropDetails? details) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop Details', style: Get.textTheme.titleLarge),
            SizedBox(height: 10),
            _buildDetailRow('Crop Type', details!.cropType!.name!),
            _buildDetailRow('Harvest Frequency', details.harvestingType!.name!),
            _buildDetailRow(
              'Plantation Date',
              details.plantationDate.toString(),
            ),
            _buildDetailRow(
              'Measurement',
              '${details.measurementValue} ${details.measurementUnit!.name}',
            ),
            // _buildDetailRow('Patta Number', '${details.} '),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Get.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(flex: 3, child: Text(value, style: Get.textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildSurveyDetailsSection(MyCropDetails? details) {
    if (details!.surveyDetails!.isEmpty) return SizedBox();

    return Card(
      elevation: 1,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

        child: ExpansionTile(
          title: Text('Survey Details (${details.surveyDetails!.length})'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Survey No')),
                  DataColumn(label: Text('Area')),
                ],
                rows: details.surveyDetails!.map((survey) {
                  return DataRow(
                    cells: [
                      DataCell(Text(survey.surveyNo!)),
                      DataCell(
                        Text(
                          '${survey.measurementValue} ${survey.measurementUnit}',
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //   Widget _buildLocationSection(CropLandDetails land) {
  //     return Card(
  //       child: Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Location', style: Get.textTheme.titleLarge),
  //             SizedBox(height: 10),

  //             SizedBox(height: 10),
  //             Container(
  //               height: 200,
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Center(
  //                 // child: Text(
  //                 //   'Map View\nLat: ${land.latitude}, Lng: ${land.longitude}',
  //                 // ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
}
