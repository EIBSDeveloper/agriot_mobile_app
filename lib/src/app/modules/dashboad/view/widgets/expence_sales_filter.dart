import 'package:argiot/src/app/modules/dashboad/view/widgets/buttom_sheet_scroll_button.dart';
import 'package:argiot/src/app/modules/expense/controller/expense_controller.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/app/widgets/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenceSalesFilter extends GetView<ExpenseController> {
  const ExpenceSalesFilter({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ButtomSheetScrollButton(),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: TitleText('Expence Sales Filter'.tr, color: Colors.black),
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: TitleText("Time line", color: Colors.black)),
            const SizedBox(width: 10),
            Expanded(
              child: InputCardStyle(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedPeriod.value,
                    padding: const EdgeInsets.all(0),
                    alignment: AlignmentDirectional.center,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    isExpanded: true,
                    items: ['week', 'month', 'year']
                        .map(
                          (period) => DropdownMenuItem(
                            value: period,
                            child: Text(period.tr),
                          ),
                        )
                        .toList(),
                    onChanged: controller.changePeriod,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
             Expanded(child: TitleText("vendor".tr, color: Colors.black)),
            const SizedBox(width: 10),
            Expanded(
              child: InputCardStyle(
                      padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                        child: DropdownButtonFormField<int>(
                          // validator: (value) => value == null ? 'required_field'.tr : null,
                          decoration:  InputDecoration(
                            hintText: 'vendor'.tr,
                            border: InputBorder.none,
                          ),

                          icon: const Icon(Icons.keyboard_arrow_down),
                          initialValue: controller.selectedVendor.value,
                          onChanged: (value) =>
                              controller.selectedVendor.value = value,
                          items: controller.vendorList
                              .map(
                                (customer) => DropdownMenuItem<int>(
                                  value: customer.id,
                                  child: Text(customer.name),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
             Expanded(child: TitleText("customer".tr, color: Colors.black)),

            const SizedBox(width: 10),
            Expanded(
              child: InputCardStyle(
           padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
          child: DropdownButtonFormField<int>(
            icon: const Icon(Icons.keyboard_arrow_down),
            decoration: InputDecoration(
              labelText: 'customer'.tr,
              border: InputBorder.none,
            ),
            initialValue: controller.selectedCustomer.value,
            onChanged: (value) => controller.selectedCustomer.value = value,
            items: controller.customerList
                .map(
                  (customer) => DropdownMenuItem<int>(
                    value: customer.id,
                    child: Text(customer.name),
                  ),
                )
                .toList(),
            validator: (value) =>
                value == null ? 'please_select_a_customer'.tr : null,
          ),
        )
            ),
          ],
        ),            const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // controller.updateWidgetConfiguration(
            //   controller.widgetConfig.value,
            // );
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: FittedBox(fit: BoxFit.scaleDown, child: Text('clear'.tr)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
