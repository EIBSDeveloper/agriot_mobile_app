import 'package:argiot/src/app/modules/expense/expense_overview_screen.dart';
import 'package:argiot/src/core/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboad/view/screens/dashboard_view.dart';
import '../../forming/view/screen/forming_page.dart';
import '../../inventory/view/inventory_overview.dart';
import '../../task/view/screens/screen.dart';

class BottomBarContoller extends GetxController {
  final RxList<Widget> pages = <Widget>[
    const DashboardView(),
    const FormingView(),const ExpenseOverviewScreen(),const InventoryOverview(),
    const TaskView()
  ].obs;

  final List<String> icons = [
    AppIcons.home,
    AppIcons.myCrop,
    AppIcons.expense,
    AppIcons.inventory,
    AppIcons.task
  ];
  final RxInt selectedIndex = 0.obs;
  late final PageController pageController;

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
