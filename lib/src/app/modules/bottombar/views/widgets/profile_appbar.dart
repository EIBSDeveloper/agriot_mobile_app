import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/app_images.dart';
import '../../../../controller/app_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../service/utils/utils.dart';
import '../../../notification/controller/notification_controller.dart';
import '../../contoller/user_profile_controller.dart';

class ProfileAppBar extends GetView<UserProfileController>
    implements PreferredSizeWidget {
  const ProfileAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) => AppBar(
    backgroundColor: Get.theme.colorScheme.primaryContainer,
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
        icon: NotificationIconButton(),
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
              appData.appLanguage(locale);
              Get.back();
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

class NotificationIconButton extends StatelessWidget {
  final NotificationController controller = Get.put(NotificationController());

  NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final unread = controller.unreadNotifications.value;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {
            Get.toNamed(Routes.notification);
          },
          icon: Icon(
            Icons.notifications_none,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        if (unread > 0)
          Positioned(
            right: 7,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  });
}
