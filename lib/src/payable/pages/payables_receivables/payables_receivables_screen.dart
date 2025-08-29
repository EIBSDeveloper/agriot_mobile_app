// lib/pages/payables_receivables/payables_receivables_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/payables_receivables_controller/payables_receivables_controller.dart';
import '../../repository/payables_receivables_repository/payables_receivables_repository.dart';
import '../../widgets/payable_receivableswidget/payablesListWidget.dart';
import '../../widgets/payable_receivableswidget/receivablesListWidget.dart';
import '../../widgets/payable_receivableswidget/togglebuttonWidget.dart';

class PayablesReceivablesPage extends StatefulWidget {
  

  const PayablesReceivablesPage({super.key, });

  @override
  _PayablesReceivablesPageState createState() =>
      _PayablesReceivablesPageState();
}

class _PayablesReceivablesPageState extends State<PayablesReceivablesPage>
    with SingleTickerProviderStateMixin {
  final RxInt selectedTopToggle = 0.obs; // 0 = Customer, 1 = Vendor, 2 = Both
  final RxInt selectedSubToggle = 0.obs; // for Both: 0 = Customer, 1 = Vendor

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    final controller = Get.put(
      PayablesReceivablesController(
        repository: PayablesReceivablesRepository(),
      ),
    );
    controller.fetchData();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayablesReceivablesController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Payables & Receivables')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text('Error: ${controller.errorMessage.value}'));
        }
        final data = controller.data.value;
        if (data == null) {
          return const Center(child: Text('No data found'));
        }

        return Column(
          children: [
            const SizedBox(height: 16),

            /// TOP TOGGLE: Customer / Vendor / Both
            TopToggleButtons(
              selectedTopToggle: selectedTopToggle,
              onToggle: (index) {
                selectedTopToggle.value = index;
                tabController.index = 0; // reset to first tab
              },
            ),

            const SizedBox(height: 16),

            /// SUB TOGGLE (only visible if "Both" is selected)
            if (selectedTopToggle.value == 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Customer"),
                    selected: selectedSubToggle.value == 0,
                    onSelected: (_) => selectedSubToggle.value = 0,
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text("Vendor"),
                    selected: selectedSubToggle.value == 1,
                    onSelected: (_) => selectedSubToggle.value = 1,
                  ),
                ],
              ),

            const SizedBox(height: 16),

            /// TAB BAR for Payables / Receivables
            TabBar(
              controller: tabController,
              tabs: const [Tab(text: 'Payables'), Tab(text: 'Receivables')],
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
            ),

            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  /// PAYABLES TAB
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() => buildPayablesTab(data)),
                  ),

                  /// RECEIVABLES TAB
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Obx(() => buildReceivablesTab(data)),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  /// PAYABLES based on selected top/sub toggle
  Widget buildPayablesTab(data) {
    int currentToggle = selectedTopToggle.value;
    int subToggle = selectedSubToggle.value;

    if (currentToggle == 0) {
      return PayablesList(
        selectedTopToggle: 0,
        customerPayables: data.customerPayables,
      );
    } else if (currentToggle == 1) {
      return PayablesList(
        selectedTopToggle: 1,
        vendorPayables: data.vendorPayables,
      );
    } else if (currentToggle == 2 && subToggle == 0) {
      return PayablesList(
        selectedTopToggle: 2,
        bothCustomerVendorPayables:
            data.bothCustomerVendorPayables
                ?.where(
                  (e) => e.customerName != null && e.customerName!.isNotEmpty,
                )
                .toList(),
      );
    } else if (currentToggle == 2 && subToggle == 1) {
      return PayablesList(
        selectedTopToggle: 2,
        bothCustomerVendorPayables:
            data.bothCustomerVendorPayables
                ?.where((e) => e.vendorName != null && e.vendorName!.isNotEmpty)
                .toList(),
      );
    }
    return const SizedBox();
  }

  /// RECEIVABLES based on selected top/sub toggle
  Widget buildReceivablesTab(data) {
    int currentToggle = selectedTopToggle.value;
    int subToggle = selectedSubToggle.value;

    if (currentToggle == 0) {
      return ReceivablesList(
        
        selectedTopToggle: 0,
        customerReceivables: data.customerReceivables,
      );
    } else if (currentToggle == 1) {
      return ReceivablesList(
       
        selectedTopToggle: 1,
        vendorReceivables: data.vendorReceivables,
      );
    } else if (currentToggle == 2 && subToggle == 0) {
      return ReceivablesList(
        selectedTopToggle: 2,
        bothCustomerVendorReceivables:
            data.bothCustomerVendorReceivables
                ?.where(
                  (e) => e.customerName != null && e.customerName!.isNotEmpty,
                )
                .toList(),
      );
    } else if (currentToggle == 2 && subToggle == 1) {
      return ReceivablesList(
        selectedTopToggle: 2,
        bothCustomerVendorReceivables:
            data.bothCustomerVendorReceivables
                ?.where((e) => e.vendorName != null && e.vendorName!.isNotEmpty)
                .toList(),
      );
    }
    return const SizedBox();
  }
}
