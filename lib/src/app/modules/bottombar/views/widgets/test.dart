import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_images.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../utils.dart';
import '../../contoller/user_profile_controller.dart';

class ProfileAppBar extends GetView<UserProfileController>
    implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(223, 229, 235, 209),
      title: SizedBox(
        height: 40,
        child: Image.asset(AppImages.logo, fit: BoxFit.fitHeight),
      ),
      actions: [
        IconButton(
          onPressed: showLanguageDialog,
          icon: Icon(Icons.translate, color: Get.theme.primaryColor),
        ),
        IconButton(
          onPressed: () {
            Get.toNamed(Routes.notification);
          },
          icon: Icon(
            Icons.notifications_none,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        IconButton(
          onPressed: () {
            packageRefresh();
            Get.toNamed(Routes.profile);
          },
          icon: Icon(
            Icons.account_circle_outlined,
            color: Get.theme.primaryColor,
          ),
        ),
      ],
    );
  }

  void showLanguageDialog() {
    Locale currentLocale = Get.locale ?? const Locale('en', 'US');
    String selectedValue = currentLocale.languageCode;

    Get.defaultDialog(
      title: 'choose_language'.tr,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('English'),
                value: 'en',
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() => selectedValue = value!);
                  Get.updateLocale(const Locale('en', 'US'));
                  Get.back();
                },
              ),
              RadioListTile(
                title: const Text('Tamil'),
                value: 'ta',
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() => selectedValue = value!);
                  Get.updateLocale(const Locale('ta', 'IN'));
                  Get.back();
                },
              ),
              RadioListTile(
                title: const Text('Hindi'),
                value: 'hi',
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() => selectedValue = value!);
                  Get.updateLocale(const Locale('hi', 'IN'));
                  Get.back();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
