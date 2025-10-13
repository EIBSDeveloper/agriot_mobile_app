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
    if (appdata.permission.value?.land?.view != 0) {
      list.add(const FormingView());
    }
    if (appdata.permission.value?.expense?.view != 0) {
      list.add(const ExpenseOverviewScreen());
    }

    // if (appdata.permission.value?.fuel?.view != 0) {
    list.add(const InventoryOverview());
    // }
    if (appdata.permission.value?.schedule?.view != 0) {
      list.add(const TaskView());
    }
    // list.addAll([
    //   const FormingView(),
    //   const ExpenseOverviewScreen(),
    //   const InventoryOverview(),
    //   const TaskView(),
    // ]);
    return list.obs;
  }

  List<String> get icons {
    final list = <String>[];
    if (appdata.permission.value?.dashboard?.view != 0) {
      list.add(AppIcons.homeSvg);
    }
    if (appdata.permission.value?.land?.view != 0) {
      list.add(AppIcons.treeSapling);
    }
    if (appdata.permission.value?.expense?.view != 0) {
      list.add(AppIcons.calculatorMoney);
    }
    // if (appdata.permission.value?.dashboard?.view != 0) {
      list.add(AppIcons.farm);
    // }
    if (appdata.permission.value?.schedule?.view != 0) {
      list.add(AppIcons.toDoAlt);
    }
    // list.addAll([
    //   AppIcons.treeSapling,
    //   AppIcons.calculatorMoney,
    //   AppIcons.farm,
    //   AppIcons.toDoAlt,
    // ]);
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
