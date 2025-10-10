import 'package:argiot/src/app/modules/home/views/widgets/notification_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_images.dart';
import '../../../../controller/app_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../contoller/user_profile_controller.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  ProfileAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(60);
  final UserProfileController controller = Get.put(UserProfileController());
  @override
  Widget build(BuildContext context) => AppBar(
    iconTheme: IconThemeData(color: Get.theme.primaryColor),
    backgroundColor: Get.theme.colorScheme.primaryContainer.withAlpha(180),
    title: Get.size.width > 450
        ? SizedBox(
            height: 40,
            child: Image.asset(AppImages.logo, fit: BoxFit.fitHeight),
          )
        : null,
    actions: [
      IconButton(
        onPressed: showLanguageDialog,
        icon: Icon(Icons.translate, color: Get.theme.primaryColor),
      ),
      Obx(
        () => controller.isShowProfile.value
            ? IconButton(
                onPressed: () {
                  Get.toNamed(Routes.notification);
                },
                icon: NotificationIconButton(),
              )
            : const SizedBox(),
      ),

      Obx(
        () => controller.isShowProfile.value
            ? IconButton(
                onPressed: () {
                  Get.toNamed(Routes.profile);
                },
                icon: Icon(
                  Icons.account_circle_outlined,
                  color: Get.theme.primaryColor,
                ),
              )
            : const SizedBox(),
      ),
    ],
  );

  void showLanguageDialog() {
    Locale currentLocale = Get.locale ?? const Locale('en', 'US');
    String selectedValue = currentLocale.languageCode;
    AppDataController appData = Get.find();
    Get.defaultDialog(
      title: 'choose_language'.tr,
      content: StatefulBuilder(
        builder: (context, setState) => RadioGroup<String>(
          groupValue: selectedValue,
          onChanged: (value) {
            if (value != null) {
              setState(() => selectedValue = value);

              Locale locale;
              switch (value) {
                case 'ta':
                  locale = const Locale('ta', 'IN');
                  break;
                case 'hi':
                  locale = const Locale('hi', 'IN');
                  break;
                case 'en':
                default:
                  locale = const Locale('en', 'US');
                  break;
              }

              Get.updateLocale(locale);
              appData.appLanguage.value = locale;
              Get.offAllNamed(Routes.home);
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(title: Text('English'), value: 'en'),
              RadioListTile<String>(title: Text('Tamil'), value: 'ta'),
              RadioListTile<String>(title: Text('Hindi'), value: 'hi'),
            ],
          ),
        ),
      ),
    );
  }
}
