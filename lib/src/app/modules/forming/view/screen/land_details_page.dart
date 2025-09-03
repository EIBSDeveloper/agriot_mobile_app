import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../utils.dart';
import '../../../subscription/package_model.dart';
import '../../controller/land_detail_controller.dart';
import '../../model/land_detail_model.dart';
import '../widget/crop_card.dart';

class LandDetailView extends GetView<LandDetailController> {
  const LandDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: CustomAppBar(
          title: controller.landDetails['name'] ?? 'Loading...',
          showBackButton: true,
          actions: [
            IconButton(
              onPressed: () {
                final landId = Get.arguments as int;
                Get.toNamed('/add-land', arguments: {'landId': landId})?.then((
                  result,
                ) {
                  controller.loadData();
                });
              },
              icon: Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                controller.deleteLandDetails(Get.arguments as int);
              },
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            controller.loadData();
            return;
          },
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (controller.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.error.value),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  controller.fetchLandDetails(Get.arguments as int),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          // Header Section
          _buildHeaderSection(),
          SizedBox(height: 8),

          Divider(), SizedBox(height: 8),
          _buildSurveySection(),
          SizedBox(height: 8),

          Divider(), SizedBox(height: 8),
          // Crops
          _buildCropsSection(),
          SizedBox(height: 8),

          Divider(), SizedBox(height: 8),
          // Documents
          _buildDocumentsSection(),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText('Land Details'),
        SizedBox(height: 10),
        _buildDetailRow(
          'Soil Type',
          controller.landDetails['soil_type']!['name'] ?? "",
        ),
        _buildDetailRow('Address', ' '),

        _buildDetailRow(
          'Patta No',
          controller.landDetails['patta_number'] ?? 'Not available',
        ),
        _buildDetailRow(
          'Measurement',
          '${controller.landDetails['measurement_value']} ${controller.landDetails['measurement_unit']['name']}',
        ),
        if (controller.landDetails['description'] != null)
          _buildDetailRow('Description', controller.landDetails['description']),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       ElevatedButton.icon(
        //         icon: Icon(Icons.map),
        //         label: Text('Map'),
        //         onPressed: () => controller.viewOnMap(
        //           controller.landDetails['latitude'],
        //           controller.landDetails['longitude'],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildSurveySection() {
    final surveys = controller.landDetails['survey_details'] as List? ?? [];
    if (surveys.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText('Survey Details '),

        // SizedBox(height: 8),
        ...surveys.asMap().entries.map<Widget>((entry) {
          int index = entry.key;
          var survey = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 8, left: 20),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Get.theme.primaryColor.withAlpha(180),
                child: Text('${index + 1}'), // showing 1-based index
              ),
              title: Text(
                'Survey No: ${survey['survey_no']}',
                style: Get.theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${survey['survey_measurement_value']} ${survey['survey_measurement_unit']}',
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    final documents = controller.landDetails['documents'] as List? ?? [];
    if (documents.isEmpty) return SizedBox();

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleText('Documents'),
            SizedBox(height: 8),
            ...documents.map((doc) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: doc['documents'].map<Widget>((list) {
                  return ActionChip(
                    avatar: Icon(Icons.picture_as_pdf),
                    label: Text(list['document_category']['name']),
                    onPressed: () =>
                        controller.viewDocument(list['upload_document']),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCropsSection() {
    final crops = controller.landDetails['crop_details'] as List? ?? [];
    if (crops.isEmpty) return addNewCrop();
    var crop = crops.map((e) {
      return CropCardModel.fromJson(e);
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleText('Crops'),
        SizedBox(height: 8),
        ...crop.map(
          (crop) => InkWell(
            onTap: () {
              Get.toNamed(
                '/crop-overview',
                arguments: {
                  'landId': controller.landDetails['id'],
                  'cropId': crop.id,
                },
              )?.then((result) {
                controller.loadData();
              });
            },
            child: CropCard(crop: crop),
          ),
        ),
        addNewCrop(),
      ],
    );
  }

  Widget addNewCrop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            PackageUsage? package = findLimit();

            if (package!.cropBalance > 0) {
              Get.toNamed(
                Routes.addCrop,
                arguments: controller.landDetails['id'],
              );
            } else {
              showDefaultGetXDialog("Crop");
            }
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
