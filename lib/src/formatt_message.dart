import 'package:argiot/src/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
class FormattedMessageContent extends StatelessWidget {
  final MessageModel message;

  const FormattedMessageContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message.text,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: MarkdownBody(
        data: message.text,
        styleSheet: MarkdownStyleSheet(
          p: Get.textTheme.bodyMedium?.copyWith(
            color: Get.isDarkMode ? Colors.white : Colors.black87,
          ),
          strong: Get.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Get.isDarkMode ? Colors.white : Colors.black87,
          ),
          em: Get.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: Get.isDarkMode ? Colors.white : Colors.black87,
          ),
          code: Get.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
            color: Get.isDarkMode ? Colors.white : Colors.black87,
          ),
          codeblockDecoration: BoxDecoration(
            color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        selectable: true,
      ),
    );
  }
}