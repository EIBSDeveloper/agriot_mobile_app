import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/my_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../routes/app_routes.dart';
import '../../../../widgets/loading.dart';
import '../../../../widgets/title_text.dart';
import '../../controller/profile_controller.dart';
import '../../model/profile_model.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'profile'.tr,
      showBackButton: true,
      // actions: [
      //   IconButton(
      //     onPressed: () {
      //       Get.toNamed(  Routes.vendorCustomer,);
      //     },
      //     icon: const Icon(Icons.account_box),
      //   ),
      // ],
    ),

    body: Obx(() {
      if (controller.isLoading.value) {
        return const Loading();
      }

      final profile = controller.profile.value;
      if (profile == null) {
        return Center(child: Text('no_profile_data_available'.tr));
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchProfile(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _buildProfileCard(profile, context),
              _buildSubscriptionCard(profile),
              _buildContactCard(profile),
              _buildCompanyCard(profile),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: Text('logout'.tr),
                onPressed: () => _showLogoutConfirmation(controller),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(color: Colors.red.shade400),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }),
    // floatingActionButton: FloatingActionButton(
    //   onPressed: () {
    //     AppDataController appData = Get.find();
    //     appData.error.value = !appData.error.value;
    //   },
    //   backgroundColor: Get.theme.primaryColor,
    //   child: const Icon(Icons.error),
    // ),
  );

  void _showLogoutConfirmation(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ProfileModel profile, BuildContext context) => Card(
    color: Colors.grey.withAlpha(30),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          if (controller.isSubmitting.value)
            CircleAvatar(
              radius: 40,
              backgroundColor: Get.theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: LoadingAnimationWidget.hexagonDots(
                  color: Get.theme.primaryColor,
                  size: 40,
                ),
              ),
            )
          else if (profile.imgUrl!.isNotEmpty)
            CircleAvatar(
              radius: 40,
              backgroundColor: Get.theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: MyNetworkImage(profile.imgUrl!),
              ),
            )
          else
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(profile.name),
                const SizedBox(height: 4),
                Text(profile.phone, style: Get.textTheme.bodyLarge),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Get.theme.primaryColor),
            onPressed: () {
              Get.toNamed(Routes.profileEdit);
              // Navigate to edit profile
            },
          ),
        ],
      ),
    ),
  );

  Widget _buildSubscriptionCard(ProfileModel profile) {
    if (profile.subscriptions.isEmpty) {
      return const SizedBox();
    }

    final subscription = profile.subscriptions.last;
    return Card(
      color: Colors.grey.withAlpha(30), //rgb(226,237,201)
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleText('current_plan'.tr),

                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.subscriptionUsage);
                  },
                  child: Chip(
                    backgroundColor: Colors.white,
                    label: Text(
                      subscription.packageName,
                      style: Get.textTheme.bodyLarge!.copyWith(
                        color: Get.theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSubscriptionDetailRow(
              'validity'.tr,
              '${subscription.packageValidity} ${subscription.packageDuration}',
            ),
            _buildSubscriptionDetailRow(
              'start_date'.tr,
              subscription.startDate,
            ),
            _buildSubscriptionDetailRow('end_date'.tr, subscription.endDate),
            _buildSubscriptionDetailRow(
              'remaining_days'.tr,
              '${subscription.remainingDays} days',
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.subscriptionPlans);
              },
              child: Text("explore_plans".tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Get.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: Get.textTheme.bodyLarge!.copyWith(
            // fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildContactCard(ProfileModel profile) => Card(
    color: Colors.grey.withAlpha(30),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText('contact_information'.tr),
          const SizedBox(height: 12),
          _buildContactDetailRow(Icons.email, profile.email),
          if (profile.doorNo.isNotEmpty)
            _buildContactDetailRow(Icons.location_on, profile.doorNo),
        ],
      ),
    ),
  );

  Widget _buildCompanyCard(ProfileModel profile) =>
      (profile.description != null ||
          profile.taxNo != null ||
          profile.companyName != null)
      ? Card(
          color: Colors.grey.withAlpha(30), //rgb(226,237,201)
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText('company_details'.tr),
                const SizedBox(height: 12),
                _buildDetailRow('company_name'.tr, profile.companyName),
                _buildDetailRow('tax_number'.tr, profile.taxNo),

                _buildDetailRow('description'.tr, profile.description),
              ],
            ),
          ),
        )
      : const SizedBox();

  Widget _buildContactDetailRow(IconData icon, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Get.theme.primaryColor),
        const SizedBox(width: 12),
        Flexible(child: Text(value, style: Get.textTheme.bodyLarge!)),
      ],
    ),
  );

  Widget _buildDetailRow(String label, String? value) =>
      (value == null || value == '')
      ? const SizedBox()
      : SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Get.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Get.textTheme.bodyLarge!),
              ],
            ),
          ),
        );
}
