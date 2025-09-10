
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/my_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../widgets/title_text.dart';
import '../../controller/profile_controller.dart';
import '../../model/profile_model.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed('/vendor-customer');
            },
            icon: const Icon(Icons.account_box),
          ),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.profile.value;
        if (profile == null) {
          return const Center(child: Text('No profile data available'));
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
                  label: const Text('Logout'),
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
    );

  void _showLogoutConfirmation(ProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileCard(ProfileModel profile, BuildContext context) => Card(
      color: Colors.grey.withAlpha(30), //rgb(226,237,201)
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            if (profile.imgUrl!.isNotEmpty)
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color.fromARGB(205, 226, 237, 201),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: MyNetworkImage(profile.imgUrl!),
                ),
              ),
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
                const TitleText('Current Plan'),

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
              'Validity',
              '${subscription.packageValidity} ${subscription.packageDuration}',
            ),
            _buildSubscriptionDetailRow('Start Date', subscription.startDate),
            _buildSubscriptionDetailRow('End Date', subscription.endDate),
            _buildSubscriptionDetailRow(
              'Remaining Days',
              '${subscription.remainingDays} days',
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.subscriptionPlans);
              },
              child: const Text("Explore Plans"),
            ),

            // LinearProgressIndicator(
            //   value: (subscription.remainingDays / subscription.packageValidity)
            //       .clamp(0.0, 1.0),
            //   backgroundColor: Get.theme.dividerColor,
            //   valueColor: AlwaysStoppedAnimation<Color>(
            //     subscription.remainingDays > 7
            //         ? Colors.green
            //         : subscription.remainingDays > 3
            //         ? Colors.orange
            //         : Colors.red,
            //   ),
            // ),
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
            style: Get.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
            const TitleText('Contact Information'),
            const SizedBox(height: 12),
            _buildContactDetailRow(Icons.email, profile.email),
            if (profile.doorNo.isNotEmpty)
              _buildContactDetailRow(Icons.location_on, profile.doorNo),
          ],
        ),
      ),
    );

  Widget _buildCompanyCard(ProfileModel profile) => (profile.description != null ||
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
                  const TitleText('Company Details'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Company Name', profile.companyName),
                  _buildDetailRow('Tax Number', profile.taxNo),

                  _buildDetailRow('Description', profile.description),
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

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value == '') {
      return Container();
    }
    return SizedBox(
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
}
