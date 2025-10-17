import 'package:argiot/src/app/modules/dashboad/controller/dashboard_controller.dart';
import 'package:argiot/src/app/modules/dashboad/view/widgets/buttom_sheet_scroll_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class WidgetSettings extends GetView<DashboardController> {
  const WidgetSettings({super.key});

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
          child: Text(
            'widget_settings'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              _buildWidgetToggle(
                'weather_payments'.tr,
                controller.widgetConfig.value.weatherAndPayments,
                (value) {
                  controller.widgetConfig.update((val) {
                    val?.weatherAndPayments = value;
                  });
                },
              ),
              _buildWidgetToggle(
                'finance_graph'.tr,
                controller.widgetConfig.value.expensesSales,
                (value) {
                  controller.widgetConfig.update((val) {
                    val?.expensesSales = value;
                  });
                },
              ),
              _buildWidgetToggle(
                'guidelines'.tr,
                controller.widgetConfig.value.guidelines!,
                (value) {
                  controller.widgetConfig.update((val) {
                    val?.guidelines = value;
                  });
                },
              ),
              _buildWidgetToggle(
                'market_prices'.tr,
                controller.widgetConfig.value.marketPrice,
                (value) {
                  controller.widgetConfig.update((val) {
                    val?.marketPrice = value;
                  });
                },
              ),
              _buildWidgetToggle(
                'tasks'.tr,
                controller.widgetConfig.value.scheduleTask,
                (value) {
                  controller.widgetConfig.update((val) {
                    val?.scheduleTask = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ElevatedButton(
            //   onPressed: () => Get.back(),
            //   child: FittedBox(
            //     fit: BoxFit.scaleDown,
            //     child: Text('close'.tr),
            //   ),
            // ),
            ElevatedButton(
              onPressed: () {
                controller.updateWidgetConfiguration(
                  controller.widgetConfig.value,
                );
                Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: FittedBox(fit: BoxFit.scaleDown, child: Text('save'.tr)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  Widget _buildWidgetToggle(
    String title,
    bool value,
    Function(bool) onChanged,
  ) => SwitchListTile(
    title: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(title, textAlign: TextAlign.start),
    ),
    // activeThumbColor: Get.theme.primaryColor,
    inactiveThumbColor: Get.theme.primaryColor,
    activeTrackColor: Get.theme.primaryColor,
    value: value,
    onChanged: onChanged,
  );
}
