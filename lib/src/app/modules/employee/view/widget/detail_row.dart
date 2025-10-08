import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isImportant;
  final Widget? isAddAction;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isImportant = false,
    this.isAddAction ,
  });

  @override
  Widget build(BuildContext context) =>value.isEmpty?const SizedBox(): Padding(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label.tr,
              style: Get.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value.isNotEmpty ? value : 'not_available'.tr,
                  style: Get.theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isImportant ? FontWeight.w600 : FontWeight.normal,
                    color: isImportant 
                        ? Get.theme.colorScheme.primary 
                        : Get.theme.colorScheme.onSurfaceVariant,
                    fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                const Spacer(),
  isAddAction??const SizedBox()
                 
              ],
            ),
          ),
        ],
      ),
    );
}