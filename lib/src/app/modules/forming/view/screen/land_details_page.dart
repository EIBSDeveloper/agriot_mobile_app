import 'package:argiot/src/app/modules/forming/model/crop_card_model.dart';
import 'package:argiot/src/app/modules/forming/model/document_view.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/subscription/model/package_usage.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_icons.dart';
import '../../../../routes/app_routes.dart';
import '../../../../service/utils/utils.dart';
import '../../controller/land_detail_controller.dart';
import '../widget/crop_card.dart';
import '../widget/document_section.dart';

class LandDetailView extends GetView<LandDetailController> {
  const LandDetailView({super.key});

  @override
  Widget build(BuildContext context) => Obx(
    () => Scaffold(
      appBar: CustomAppBar(
        title: controller.landDetails['name'] ?? 'Loading...',
        showBackButton: true,
        actions: [
          IconButton(
            color: Get.theme.primaryColor,
            onPressed: () {
            
              Get.toNamed('/add-land', arguments: {'landId': controller.landId.value})?.then((
                result,
              ) {
                controller.loadData();
              });
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              controller.deleteLandDetails(controller.landId.value);
            },
            color: Get.theme.primaryColor,
            icon: const Icon(Icons.delete),
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

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.error.value),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  controller.fetchLandDetails(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header Section
          _buildHeaderSection(),
          const SizedBox(height: 8),

          const Divider(), const SizedBox(height: 8),
          _buildSurveySection(),
          const SizedBox(height: 8),

          const Divider(),
          _buildDocumentsSection(),
          const SizedBox(height: 8),
          // Crops
          _buildCropsSection(),

          // Documents
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const TitleText('Land Details'),
          const Spacer(),
                  InkWell(
                    onTap: () {
                      Get.toNamed(Routes.landMapView,arguments: {'landId': controller.landId.value });
                    },
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.asset(AppIcons.map),
                    ),
                  ),
        ],
      ),
      const SizedBox(height: 10),
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

  Widget _buildSurveySection() {
    final surveys = controller.landDetails['survey_details'] as List? ?? [];
    if (surveys.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Survey Details '),

        // SizedBox(height: 8),
        ...surveys.asMap().entries.map<Widget>((entry) {
          int index = entry.key;
          var survey = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 20),
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
    if (documents.isEmpty) return const SizedBox();

    List<DocumentView> allDocs = [];

    for (var doc in documents) {
      final List innerDocs = doc['documents'] ?? [];
      allDocs.addAll(
        innerDocs.map(
          (e) => DocumentView(
            label: e['document_category']['name'],
            url: e['upload_document'],
          ),
        ),
      );
    }

    return DocumentSection(docs: allDocs);
  }

  Widget _buildCropsSection() {
    final crops = controller.landDetails['crop_details'] as List? ?? [];
    if (crops.isEmpty) return addNewCrop();
    var crop = crops.map((e) => CropCardModel.fromJson(e));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Crops'),
        const SizedBox(height: 8),
        ...crop.map(
          (crop) => InkWell(
            onTap: () {
              Get.toNamed(
                Routes.cropOverview,
                arguments: {
                  'landId': controller.landId.value,
                  'cropId': crop.id,
                },
              )?.then((result) {
               if(result??false){
                 controller.loadData();
               }
              });
            },
            child: CropCard(crop: crop),
          ),
        ),
        addNewCrop(),
      ],
    );
  }

  Widget addNewCrop() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      OutlinedButton(
        onPressed: () async {
          PackageUsage? package =await findLimit();

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

  Widget _buildDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
