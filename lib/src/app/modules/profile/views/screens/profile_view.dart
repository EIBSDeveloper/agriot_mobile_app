import 'dart:io';

import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/app/widgets/my_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../widgets/title_text.dart';
import '../../../near_me/views/widget/widgets.dart';
import '../../controller/controller.dart';
import '../../model/model.dart';

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

// lib/app/modules/profile/views/profile_edit_view.dart
// lib/app/modules/profile/views/profile_edit_view.dart

class ProfileEditView extends GetView<ProfileEditController> {
  const ProfileEditView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile', showBackButton: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 10),
                _buildPersonalInfoSection(),
                const SizedBox(height: 10),
                _buildAddressSection(),
                const SizedBox(height: 10),
                _buildCompanySection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        );
      }),
    );

  Widget _buildImagePicker() => Center(
      child: Stack(
        children: [
          Obx(() {
            if (controller.imagePath.isNotEmpty) {
              return CircleAvatar(
                radius: 50,
                backgroundImage: controller.imagePath.startsWith('http')
                    ? NetworkImage(controller.imagePath.value)
                    : FileImage(File(controller.imagePath.value))
                          as ImageProvider,
              );
            }
            return const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 40),
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildPersonalInfoSection() => Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.nameController,
              label: 'Full Name *',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required field' : null,
            ),
            // const SizedBox(height: 12),
            // _buildTextField(
            //   controller: controller.phoneController,
            //   label: 'Phone Number *',
            //   validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
            //   keyboardType: TextInputType.phone,
            // ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controller.emailController,
              label: 'Email *',
              validator: (value) =>
                  !GetUtils.isEmail(value ?? '') ? 'Enter valid email' : null,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );

  Widget _buildAddressSection() => Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address Information',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.doorNoController,
              label: 'Address',
              // validator: (value) =>
              //     value?.isEmpty ?? true ? 'Required field' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controller.pincodeController,
              label: 'Pincode *',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required field' : null,
              keyboardType: TextInputType.number,
            ),            const SizedBox(height: 12),
                 _buildTextField(
                controller: controller.locationController,
                label: 'Location Coordinates *',
                validator: (value) => value!.isEmpty ? 'Required field' : null,
                readOnly: true,
                onTap: controller.pickLocation,
              ),
            const SizedBox(height: 12),
            // _buildCountryDropdown(),
            // const SizedBox(height: 12),
            // _buildStateDropdown(),
            // const SizedBox(height: 12),
            // _buildCityDropdown(),
            // const SizedBox(height: 12),
            // _buildTalukDropdown(),
            // const SizedBox(height: 12),
            // _buildVillageDropdown(),
          ],
        ),
      ),
    );

  Widget _buildCompanySection() => Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Information',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: controller.companyController,
              label: 'Company Name',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controller.taxNoController,
              label: 'Tax Identification Number',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controller.descriptionController,
              label: 'Description',
            
              height: 100,
            ),
          ],
        ),
      ),
    );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    double? height,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) => InputCardStyle(
      
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          isDense: true,
          suffixIcon: readOnly ? const Icon(Icons.location_on) : null,
        ),
        validator: validator,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );

Widget _buildSubmitButton() => Obx(() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isSubmitting.value
              ? null
              : controller.submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: controller.isSubmitting.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Changes', style: TextStyle(fontSize: 16)),
        ),
      ));
}

class ExampleSlider extends StatefulWidget {
  final double min;
  final double max;
  final double initialValue;
  final bool showMinMaxText;
  final Color primaryColor;
  final TextStyle minMaxTextStyle;
  final Function(double) onChange;
  const ExampleSlider({
    required this.min,
    required this.max,
    this.initialValue = 0.0,
    required this.onChange,
    this.primaryColor = Colors.indigo,
    this.showMinMaxText = true,
    this.minMaxTextStyle = const TextStyle(fontSize: 14),
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ExampleSliderState createState() => _ExampleSliderState();
}

class _ExampleSliderState extends State<ExampleSlider> {
  late double _currentSliderValue;
  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) => SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: widget.primaryColor,
        inactiveTrackColor: widget.primaryColor.withAlpha(35),
        trackShape: const RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbShape: CustomSliderThumbCircle(
          thumbRadius: 20,
          min: widget.min,
          max: widget.max,
        ),
        thumbColor: widget.primaryColor,
        overlayColor: widget.primaryColor.withAlpha(35),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        activeTickMarkColor: widget.primaryColor,
        inactiveTickMarkColor: widget.primaryColor.withAlpha(35),
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: widget.primaryColor.withAlpha(35),
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      child: Slider(
        min: widget.min,
        max: widget.max,
        value: _currentSliderValue,
        onChanged: (value) {
          setState(() {
            _currentSliderValue = value;
          });
          widget.onChange(value);
        },
      ),
    );
}

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final double min;
  final double max;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0.0,
    this.max = 100.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors
          .white //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme.thumbColor, //Text Color of Value on Thumb
      ),
      text: getValue(value),
    );

    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    Offset textCenter = Offset(
      center.dx - (tp.width / 2),
      center.dy - (tp.height / 2),
    );

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) => (min + (max - min) * value).round().toString();
}
