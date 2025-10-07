import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/payouts/controller/payout_controller.dart';
import 'package:argiot/src/app/modules/payouts/model/payoutmodel.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Payoutlistscreen extends GetView<PayoutController> {
  const Payoutlistscreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'payout_list'.tr),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: InputCardStyle(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  size: 22,
                  color: Colors.grey,
                ),
                hintText: "search_employee".tr,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),
        ),

        Expanded(
          child: Obx(() {
            final payouts = controller.advancelist;

            return RefreshIndicator(
              onRefresh: () async {
                await controller.loadadvancelist(reset: true);
              },
              child: payouts.isEmpty
                  ? Center(child: Text("no_payouts_found".tr))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: payouts.length,
                      itemBuilder: (context, index) {
                        final pay = payouts[index];
                        return payoutCard(pay);
                      },
                    ),
            );
          }),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Get.toNamed(Routes.addPayout);
      },
      backgroundColor: Get.theme.colorScheme.primary,
      child: const Icon(Icons.add),
    ),
  );
}

Widget payoutCard(PayoutModel pay) => Card(
  elevation: 1,
  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Profile Image
        pay.image != null
            ? CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(pay.image!),
              )
            : CircleAvatar(
                radius: 35,
                backgroundColor: Get.theme.colorScheme.primary.withAlpha(80),
                child: Text(
                  pay.name.isNotEmpty ? pay.name[0].toUpperCase() : "?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),

        const SizedBox(width: 16),

        /// Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Name + Role
              Row(
                children: [
                  Text(
                    capitalizeFirstLetter(pay.name),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 5),
                  ...[
                  Text(
                    '(${pay.role})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                ],
              ),

              const SizedBox(height: 6),

              /// Salary Type
              ...[
              Text(
                "${"salary_type".tr}: ${pay.salaryType}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
              const SizedBox(height: 4),

              /// Work Type
              ...[
              Text(
                "${"work_type".tr}: ${pay.workType}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
              const SizedBox(height: 4),

              /// Working Days
              ...[
              Text(
                "${"working_days".tr}: ${pay.workingDays}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
              const SizedBox(height: 4),

              /// Paid Salary
              ...[
              Text(
                "${"paid_salary".tr}: ${pay.paidSalary}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
              const SizedBox(height: 4),

              /// Unpaid Salary
              ...[
              Text(
                "${"unpaid_salary".tr}: ${pay.unpaidSalary}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            ],
          ),
        ),
      ],
    ),
  ),
);
