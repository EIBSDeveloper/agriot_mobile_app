import 'dart:io';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/chart.dart';
import 'package:argiot/src/core/app_icons.dart';
import 'package:argiot/src/formatt_message.dart';
import 'package:argiot/src/smart_farm_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SmartFarmView extends GetView<SmartFarmController> {
  const SmartFarmView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: 'bot_title'.tr,
      //  Row(
      //   children: [
      //     Container(
      //       width: 36,
      //       height: 36,
      //       decoration: BoxDecoration(
      //         color: Get.theme.primaryColor.withOpacity(0.2),
      //         borderRadius: BorderRadius.circular(12),
      //       ),
      //       child: Icon(
      //         Icons.eco_rounded,
      //         color: Get.theme.primaryColor,
      //         size: 20,
      //       ),
      //     ),
      //     const SizedBox(width: 12),
      //     Text),
      //   ],
      // ),
      actions: [
        IconButton(
          icon: const Icon(Icons.photo_library_outlined),
          onPressed: () => controller.pickImage(ImageSource.gallery),
          tooltip: 'tooltip.gallery'.tr,
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showAboutDialog,
        ),
      ],
    ),
    body: Column(
      children: [
        // Analysis indicator
        Obx(
          () => controller.isAnalyzing.value
              ? _buildAnalysisIndicator()
              : const SizedBox.shrink(),
        ),

        // Messages list
        Expanded(
          child: Obx(
            () => controller.messages.isEmpty
                ? _buildEmptyState()
                : _buildMessagesList(),
          ),
        ),

        // Input area
        _buildInputArea(),
      ],
    ),
  );

  Widget _buildAnalysisIndicator() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    color: Get.isDarkMode
        ? Get.theme.colorScheme.surface
        : Colors.green.shade50,
    child: Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Get.theme.primaryColor),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'analyzing'.tr,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Get.theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Get.theme.primaryColor.withAlpha(100),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.eco_rounded,
            size: 40,
            color: Get.theme.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'emptyTitle'.tr,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'emptySubtitle'.tr,
          textAlign: TextAlign.center,
          style: Get.textTheme.bodyMedium?.copyWith(
            color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    ),
  );

  Widget _buildMessagesList() => ListView.builder(
    controller: controller.scrollController,
    padding: const EdgeInsets.only(top: 16, bottom: 16),
    itemCount: controller.messages.length,
    itemBuilder: (context, index) {
      final message = controller.messages[index];
      return MessageWidget(
        message: message,
        index: index,
        messages: controller.messages,
        onLongPress: () => _showMessageOptions(message),
      );
    },
  );

  Widget _buildInputArea() => Container(
    decoration: BoxDecoration(
      color: Get.isDarkMode ? Get.theme.cardTheme.color : Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, -1),
          blurRadius: 3,
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: SafeArea(
      child: Row(
        children: [
          // Camera button
          Container(
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => controller.pickImage(ImageSource.camera),
              icon: Icon(
                Icons.camera_alt_outlined,
                color: Get.theme.primaryColor,
              ),
              tooltip: 'tooltip.camera'.tr,
            ),
          ),
          const SizedBox(width: 12),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: controller.textController,
                        focusNode: controller.focusNode,
                        decoration: InputDecoration(
                          hintText: 'hintText'.tr,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        style: Get.textTheme.bodyMedium,
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty) {
                            controller.addUserMessage(text.trim());
                          }
                        },
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),

                  // Send button
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Material(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          final text = controller.textController.text.trim();
                          if (text.isNotEmpty) {
                            controller.addUserMessage(text);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('aboutTitle'.tr),
        content: Text('aboutContent'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('dialog.close'.tr),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(MessageModel message) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy, color: Get.theme.primaryColor),
              title: Text('copy'.tr),
              onTap: () {
                Get.back();
                controller.copyToClipboard(message.text);
              },
            ),
            if (message.isUser)
              ListTile(
                leading: Icon(Icons.edit, color: Get.theme.primaryColor),
                title: Text('edit'.tr),
                onTap: () {
                  Get.back();
                  _showEditMessageDialog(message);
                },
              ),
          ],
        ),
      ),
      backgroundColor: Get.theme.cardTheme.color,
    );
  }

  void _showEditMessageDialog(MessageModel message) {
    final editController = TextEditingController(text: message.text);

    Get.dialog(
      AlertDialog(
        title: Text('editMessage'.tr),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          maxLines: 5,
          minLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () {
              final updatedText = editController.text.trim();
              if (updatedText.isNotEmpty) {
                controller.updateMessage(message.id, updatedText);
                Get.back();
              }
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final MessageModel message;
  final int index;
  final List<MessageModel> messages;
  final VoidCallback onLongPress;

  const MessageWidget({
    super.key,
    required this.message,
    required this.index,
    required this.messages,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstMessage =
        index == 0 || messages[index - 1].isUser != message.isUser;
    final showAvatar = isFirstMessage;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
        top: isFirstMessage ? 8 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser && showAvatar) _buildBotAvatar(),
          if (!message.isUser && !showAvatar) const SizedBox(width: 48),
          if (message.isUser) const SizedBox(width: 0),

          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // if (isFirstMessage && !message.isUser) _buildBotName(),
                GestureDetector(
                  onLongPress: onLongPress,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Get.theme.primaryColor
                          : Get.theme.primaryColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.imagePath != null) _buildImagePreview(),
                          if (message.text.isNotEmpty)
                            FormattedMessageContent(message: message),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildTimestamp(),
              ],
            ),
          ),

          if (message.isUser && showAvatar) _buildUserAvatar(),
          if (message.isUser && !showAvatar) const SizedBox(width: 48),
          if (!message.isUser) const SizedBox(width: 0),
        ],
      ),
    );
  }

  Widget _buildBotAvatar() => Container(
    width: 36,
    height: 36,
    margin: const EdgeInsets.only(right: 12, top: 4),
    decoration: BoxDecoration(
      color: Get.theme.primaryColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    // child: Icon(Icons.eco_rounded, color: Get.theme.primaryColor, size: 20),
    child: Image.asset(AppIcons.icon),
  );

  Widget _buildUserAvatar() => Container(
    width: 36,
    height: 36,
    margin: const EdgeInsets.only(left: 12, top: 4),
    decoration: BoxDecoration(
      color: Get.theme.primaryColor.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.person, color: Colors.white, size: 20),
  );

  // Widget _buildBotName() => Padding(
  //   padding: const EdgeInsets.only(bottom: 4, left: 2),
  //   child: Text(
  //     'botName'.tr,
  //     style: Get.textTheme.bodySmall?.copyWith(
  //       fontWeight: FontWeight.w500,
  //       color: Get.theme.primaryColor,
  //     ),
  //   ),
  // );

  Widget _buildImagePreview() => Stack(
    children: [
      Image.file(
        File(message.imagePath!),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      ),
      Positioned(
        top: 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'analyzingImage'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    ],
  );

  Widget _buildTimestamp() => Padding(
    padding: const EdgeInsets.only(top: 4, left: 2, right: 2),
    child: Text(
      DateFormat.jm().format(message.timestamp),
      style: Get.textTheme.bodySmall?.copyWith(
        color: Get.isDarkMode ? Colors.grey[400] : Colors.grey[600],
        fontSize: 10,
      ),
    ),
  );
}
