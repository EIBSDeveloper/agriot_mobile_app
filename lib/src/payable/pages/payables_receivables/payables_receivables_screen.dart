
import 'package:argiot/src/payable/controller/controllerpay_receive/pay_receivecontroller.dart';
import 'package:argiot/src/payable/repository/repo_pay_receive/pay_receiverepo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/payable_receivableswidget/payables_list_widget.dart';
import '../../widgets/payable_receivableswidget/receivables_list_widget.dart';

class PayablesReceivablesPage extends StatefulWidget {
  final int initialTab;
  final int initialsubtab;
  const PayablesReceivablesPage({
    super.key,
    this.initialTab = 0,
    this.initialsubtab = 0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PayablesReceivablesPageState createState() =>
      _PayablesReceivablesPageState();
}

class _PayablesReceivablesPageState extends State<PayablesReceivablesPage>
    with SingleTickerProviderStateMixin {
  final RxInt selectedTopToggle = 0.obs; // 0 = Customer, 1 = Vendor
  late TabController tabController;

  late CustomerlistController controller;

  @override
  void initState() {
    super.initState();

    // Clear old controller if exists
    if (Get.isRegistered<CustomerlistController>()) {
      Get.delete<CustomerlistController>();
    }

    controller = Get.put(
      CustomerlistController(repository: CustomerlistRepository()),
    );

    // Fetch all data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllData();
    });

    // Open requested tab
    selectedTopToggle.value = widget.initialTab;
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialsubtab,
    );
  }

  Future<void> _refreshData() async {
    await controller.fetchAllData();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text('payables_receivables'.tr)),
      body: Obx(() {
        final isLoading =
            controller.isLoadingCustomerPayables.value ||
            controller.isLoadingCustomerReceivables.value ||
            controller.isLoadingVendorPayables.value ||
            controller.isLoadingVendorReceivables.value;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            const SizedBox(height: 16),

            /// TOP TOGGLE: Customer / Vendor
            ToggleButtons(
              isSelected: List.generate(
                2,
                (index) => index == selectedTopToggle.value,
              ),
              onPressed: (index) {
                selectedTopToggle.value = index;
                tabController.index = 0; // reset to first tab
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              color: Colors.black,
              constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
              children: [Text('customer'.tr), Text('vendor'.tr)],
            ),

            /// TAB BAR: Payables / Receivables
            TabBar(
              controller: tabController,
              tabs: [
                Tab(text: 'payables'.tr),
                Tab(text: 'receivables'.tr),
              ],
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
            ),

            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  /// PAYABLES TAB
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Obx(() => buildPayablesTab()),
                    ),
                  ),

                  /// RECEIVABLES TAB
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Obx(() => buildReceivablesTab()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );

  
  Widget buildPayablesTab() => PayablesList(selectedTopToggle: selectedTopToggle.value);

  Widget buildReceivablesTab() => ReceivablesList(selectedTopToggle: selectedTopToggle.value);
}
