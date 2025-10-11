import 'package:argiot/src/app/modules/home/views/screens/my_drawer.dart';
import 'package:argiot/src/app/widgets/svg_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../contoller/bottombar_contoller.dart';
import '../widgets/profile_appbar.dart';

class Home extends GetView<BottomBarContoller> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:  ProfileAppBar(),
    drawer: const AppDrawer(),
    body: SafeArea(
      
      child: PageView.builder(
        controller: controller.pageController,
        itemCount: controller.pages.length,
        itemBuilder: (context, index) => controller.pages[index],
        onPageChanged: (index) {
          controller.selectedIndex.value = index;
        },
      ),
    ),
    bottomNavigationBar: Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primaryContainer.withAlpha(180),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(controller.icons.length, (index) {
            bool isSelected = controller.selectedIndex.value == index;
            return Expanded(
              child: InkWell(
                onTap: () {
                  controller.selectedIndex.value = index;
                  controller.pageController.jumpToPage(index);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 60,

                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: isSelected
                        ? Get.theme.primaryColor.withAlpha(180)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: SvgIcons(

                    controller.icons[index],
                    color: isSelected ? Colors.white : Get.theme.primaryColor,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}
