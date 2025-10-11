import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/expense/view/screens/expense_overview_screen.dart';
import 'package:argiot/src/core/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboad/view/screens/dashboard_view.dart';
import '../../forming/view/screen/forming_page.dart';
import '../../inventory/view/inventory_overview.dart';
import '../../task/view/screens/task_view.dart';
class BottomBarContoller extends GetxController {
  final AppDataController appdata = Get.find();

  final RxInt selectedIndex = 0.obs;
  late final PageController pageController;

  
  RxList<Widget> get pages {
    final list = <Widget>[];
    if (appdata.permission.value?.dashboard?.view != 0) {
      list.add(const DashboardView());
    }
    list.addAll([
      const FormingView(),
      const ExpenseOverviewScreen(),
      const InventoryOverview(),
      const TaskView(),
    ]);
    return list.obs;
  }

  List<String> get icons {
    final list = <String>[];
    if (appdata.permission.value?.dashboard?.view != 0) {
      list.add(AppIcons.homeSvg);
    }
    list.addAll([
      AppIcons.treeSapling,
      AppIcons.calculatorMoney,
      AppIcons.farm,
      AppIcons.toDoAlt,
    ]);
    return list;
  }


  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: selectedIndex.value);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
