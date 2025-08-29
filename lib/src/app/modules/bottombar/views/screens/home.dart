import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../contoller/bottombar_contoller.dart';
import '../widgets/test.dart';

class Home extends GetView<BottomBarContoller> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(),
      body: SafeArea(
        child: PageView.builder(
          controller: controller.pageController,
          itemCount: controller.pages.length,
          itemBuilder: (context, index) {
            return controller.pages[index];
          },
          onPageChanged: (index) {
            controller.selectedIndex.value = index;
          },
        ),
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primaryContainer.withAlpha(180),
            borderRadius: BorderRadius.only(
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

                    padding: EdgeInsets.all(10),
                    // margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Get.theme.primaryColor.withAlpha(180)
                          : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      
                      ),
                    ),
                    child: Image.asset(
                      controller.icons[index],
                      color: isSelected ? Colors.white : const Color.fromARGB(199, 0, 0, 0),
                    
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
