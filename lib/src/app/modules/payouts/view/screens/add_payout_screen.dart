import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/payouts/controller/payout_controller.dart';
import 'package:argiot/src/app/modules/payouts/view/widget/payout_card.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../widgets/loading.dart';

class AddpayoutScreen extends GetView<PayoutController> {
  final ScrollController scrollController = ScrollController();

  AddpayoutScreen({super.key}) {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !controller.isLoading.value) {
        controller.loadadvancelist();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CustomAppBar(title: 'Add Payouts'),
    body: Obx(() {
      if (controller.isLoading.value && controller.advancelist.isEmpty) {
        return const Loading();
      }

      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(10.0),
        children: [
          const SizedBox(height: 12),

          /// Search field
          InputCardStyle(
            child: TextField(
              controller: controller.searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, size: 22, color: Colors.grey),
                hintText: "Search employee...",
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),

          const SizedBox(height: 12),

          if (controller.advancelist.isEmpty)
            const Center(child: Text("No payouts found"))
          else
            ...List.generate(
              controller.advancelist.length,
              (index) => PayoutCard(index: index),
            ),

          if (controller.hasMore.value)
            const Padding(padding: EdgeInsets.all(8.0), child: Loading()),

          const SizedBox(height: 20),
        ],
      );
    }),

    bottomNavigationBar: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            // Filter only employees that were edited
            final editedEmployees = controller.advancelist
                .where((emp) => emp.isEdited == true)
                .toList();

            if (editedEmployees.isEmpty) {
              print("No changes to submit");
              return;
            }

            // Print only edited employees
            for (var emp in editedEmployees) {
              print(
                "Employee: ${emp.name}, Deduction: ${emp.deduction}, Payout: ${emp.payoutAmount}",
              );
            }

            // Here you can call your API with editedEmployees
          },
          child: const Text('Submit'),
        ),
      ),
    ),
  );
}
