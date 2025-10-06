import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isImportant;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isImportant = false,
  });

  @override
  Widget build(BuildContext context) =>value.isEmpty?const SizedBox(): Padding(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Text(
              value.isNotEmpty ? value : 'not_available'.tr,
              style: Get.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isImportant ? FontWeight.w600 : FontWeight.normal,
                color: isImportant 
                    ? Get.theme.colorScheme.primary 
                    : Get.theme.colorScheme.onSurfaceVariant,
                fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
}