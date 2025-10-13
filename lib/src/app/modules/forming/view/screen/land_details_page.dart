import 'package:argiot/src/app/modules/forming/model/crop_card_model.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/subscription/model/package_usage.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_icons.dart';
import '../../../../routes/app_routes.dart';
import '../../../../service/utils/pop_messages.dart';
import '../../../../service/utils/utils.dart';
import '../../../../widgets/loading.dart';
import '../../../../widgets/my_network_image.dart';
import '../../controller/land_detail_controller.dart';
import '../widget/crop_card.dart';

class LandDetailView extends GetView<LandDetailController> {
  const LandDetailView({super.key});

  @override
  Widget build(BuildContext context) => Obx(
    () => Scaffold(
      appBar: CustomAppBar(
        title: controller.landDetails.value?.name ?? 'Loading...',
        showBackButton: true,
        actions: [
          IconButton(
            color: Get.theme.primaryColor,
            onPressed: () {
              Get.toNamed(
                 Routes.addLand,
                arguments: {'landId': controller.landId.value},
              )?.then((result) {
                controller.loadData();
              });
            },
            icon: const Icon(Icons.edit),
          ),
          // IconButton(
          //   onPressed: () {
          //     controller.deleteLandDetails(controller.landId.value);
          //   },
          //   color: Get.theme.primaryColor,
          //   icon: const Icon(Icons.delete),
          // ),
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
      return const Loading();
    }

    if (controller.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(controller.error.value),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchLandDetails(),
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
          if (controller.appDeta.permission.value?.crop?.list != 0)
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
              Get.toNamed(
                Routes.landMapView,
                arguments: {'landId': controller.landId.value},
              );
            },
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(AppIcons.map),
            ),
          ),
        ],
      ),

      _buildDetailRow(
        'Soil Type',
        controller.landDetails.value?.soilType?.name ?? "",
      ),

      _buildDetailRow(
        'Manager',
        controller.landDetails.value?.manager?.name ?? "",
      ),

      _buildDetailRow(
        'Address',
        controller.landDetails.value?.doorNo ?? "",
      ),

      _buildDetailRow(
        'Patta No',
        controller.landDetails.value?.pattaNumber ??"",
      ),
      _buildDetailRow(
        'Measurement',
        '${controller.landDetails.value?.measurementValue} ${controller.landDetails.value?.measurementUnit?.name??""}',
      ),
      if (controller.landDetails.value?.description != null)
        _buildDetailRow('Description', controller.landDetails.value?.description??""),
    ],
  );

  Widget _buildSurveySection() {
    final surveys = controller.landDetails.value?.surveyDetails ?? [];
    if (surveys.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Survey Details '),

        // SizedBox(height: 8),
        ...surveys.asMap().entries.map<Widget>((entry) {
          var survey = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 20),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              // leading: CircleAvatar(
              //   backgroundColor: Get.theme.primaryColor.withAlpha(180),
              //   child: Text('${index + 1}'), // showing 1-based index
              // ),
              title: Text(
                'Survey No: ${survey['survey_no']}',
                style: Get.theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${double.tryParse(survey['survey_measurement_value'])?.round()??0} ${survey['survey_measurement_unit_name']}',
              ),
            ),
          );
        }),
      ],
    );
  }


  Widget _buildDocumentsSection() {
    final documents = controller.landDetails.value?.documents?? [];
    if (documents.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleText('Documents',color: Colors.black,),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: documents
              .map(
                (document) => InkWell(
                  onTap: () {
                    List<String> list = document["documents"]
                        .map<String>((doc) => doc["upload_document"].toString())
                        .toList();

                    Get.toNamed(Routes.docViewer, arguments: list);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document["documents"]
                            .first["document_category"]["name"],
                      ),
                      MyNetworkImage(
                        document["documents"].first["upload_document"],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCropsSection() {
    final crops = controller.landDetails.value?.cropDetails ?? [];
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
                if (result ?? false) {
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
          PackageUsage? package = await findLimit();

          if (package!.cropBalance > 0) {
            Get.toNamed(
              Routes.addCrop,
              arguments: controller.landDetails.value?.id,
            )?.then((result) {
              if (result ?? false) {
                controller.fetchLandDetails();
              }
            });
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

  Widget _buildDetailRow(String label, String value) => value.isNotEmpty
      ? Padding(
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
        )
      : const SizedBox();
}
