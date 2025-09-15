import 'package:argiot/src/app/modules/guideline/controller/guideline_controller.dart';

import 'package:argiot/src/app/modules/guideline/model/guideline_category.dart';
import 'package:argiot/src/app/modules/guideline/view/widget/guideline_card.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuidelinesView extends GetView<GuidelineController> {
  const GuidelinesView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'guidelines_title'.tr),
    body: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildFilterRow(),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredGuidelines.isEmpty) {
                return Center(child: Text('no_guidelines_found'.tr));
              }
              return ListView.builder(
                itemCount: controller.filteredGuidelines.length,
                itemBuilder: (context, index) => GuidelineCard(
                  guideline: controller.filteredGuidelines[index],
                ),
              );
            }),
          ),
        ],
      ),
    ),
  );

  Widget _buildSearchField() => InputCardStyle(
    child: TextField(
      decoration: InputDecoration(
        labelText: 'search_placeholder'.tr,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (value) => controller.searchGuidelines(value),
    ),
  );

  Widget _buildFilterRow() => Row(
    children: [
      Expanded(
        child: Obx(
          () => InputCardStyle(
            child: DropdownButtonFormField2<GuidelineCategory>(
              isExpanded: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),

              hint: Text('select_category'.tr),
              value: controller.selectedCategory.value,
              items: [
                DropdownMenuItem<GuidelineCategory>(
                  value: GuidelineCategory(id: 0, name: "All"),
                  child: Text("All", style: Get.textTheme.bodyMedium),
                ),
                ...controller.categories.map(
                  (category) => DropdownMenuItem<GuidelineCategory>(
                    value: category,
                    child: Text(category.name, style: Get.textTheme.bodyMedium),
                  ),
                ),
              ],
              onChanged: (value) => controller.filterByCategory(value),
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.only(right: 8),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.keyboard_arrow_down),
              ),
              dropdownStyleData: const DropdownStyleData(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(BorderSide.none),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
