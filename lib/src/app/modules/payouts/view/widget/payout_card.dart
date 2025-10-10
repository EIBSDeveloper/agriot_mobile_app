import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/payout_add_controller.dart';

class PayoutCard extends GetView<PayoutAddController> {
  final int index;

  const PayoutCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final pay = controller.advancelist[index];

    // Calculated payout (recompute when deduction changes)
    int calculatedPayout() {
      final deduction = pay.deductionAdvance ?? 0;
      return (pay.paidSalary - deduction).clamp(0, double.infinity).toInt();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Employee Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage("assets/avatar.png"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pay.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      pay.salaryType,
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                    Text(
                      pay.workType,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Salary and Advance fields
            Row(
              children: [
                Expanded(
                  child: InputCardStyle(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            pay.paidSalary.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InputCardStyle(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            (pay.advance ?? 0).toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// Editable Deduction + Auto Payout
            IntrinsicHeight(
              child: Row(
                children: [
                  /// Deduction field with reactive color
                  Expanded(
                    child: InputCardStyle(
                      child: Obx(
                        () => TextField(
                          controller: controller.deductionControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            labelText: "deduction".tr,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                controller.deductionColors[index]?.value ??
                                Colors.black54,
                          ),
                          onChanged: (val) {
                            final entered = int.tryParse(val.trim()) ?? 0;
                            final adv = pay.advance ?? 0;

                            if (entered > adv) {
                              controller.deductionColors[index]?.value =
                                  Colors.red;
                            } else {
                              controller.deductionColors[index]?.value =
                                  Colors.black54;
                              pay.deductionAdvance = entered;
                              pay.payoutAmount = pay.paidSalary - entered;
                              pay.isEdited = true;
                              controller.advancelist.refresh();
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  /// Payout amount (recomputed directly)
                  Expanded(
                    child: InputCardStyle(
                      child: Obx(
                        () => TextField(
                          controller: controller.payoutControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            labelText: "payout_amount".tr,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                controller.deductionColors[index]?.value ??
                                Colors.black54,
                          ),
                          onChanged: (val) {
                            final entered = int.tryParse(val.trim()) ?? 0;
                            final adv = pay.advance ?? 0;

                            if (entered > adv) {
                              controller.deductionColors[index]?.value =
                                  Colors.red;
                            } else {
                              controller.deductionColors[index]?.value =
                                  Colors.black54;
                              pay.deductionAdvance = entered;
                              pay.payoutAmount = pay.paidSalary - entered;
                              pay.isEdited = true;
                              controller.advancelist.refresh();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              calculatedPayout().toString(),
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
