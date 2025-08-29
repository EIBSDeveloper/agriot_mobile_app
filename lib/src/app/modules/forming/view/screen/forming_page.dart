import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_icons.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../utils.dart';
import '../../../subscription/package_model.dart';
import '../../controller/forming_controller.dart';
import '../widget/land_card.dart';

class FormingView extends GetView<FormingController> {
  const FormingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLands,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Row(
                  children: [
                    TitleText("Lands".tr),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Get.toNamed(Routes.landMapView);
                      },
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(AppIcons.map),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.lands.length,
                  itemBuilder: (context, index) {
                    final land = controller.lands[index];

                    return Obx(
                      () => LandCard(
                        key: ValueKey(
                          land.id,
                        ), // Important for state preservation
                        land: land,
                        isExpanded: controller.expandedLandId.value == land.id,
                        onExpand: () => controller.toggleExpandLand(land.id),
                        onTap: () => controller.navigateToLandDetail(land.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Get.theme.primaryColor,
        onPressed: () {
          PackageUsage? package = findLimit();

          if (package!.landBalance > 0) {
            Get.toNamed(Routes.addLand);
          } else {
            showDefaultGetXDialog("Land");
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
