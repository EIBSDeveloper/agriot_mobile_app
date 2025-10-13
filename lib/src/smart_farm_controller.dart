import 'dart:io';

import 'package:argiot/src/chart.dart';
import 'package:argiot/src/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'app/service/utils/pop_messages.dart';

class SmartFarmController extends GetxController {
  final ChatRepository repository;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isAnalyzing = false.obs;
  final RxBool isLoading = false.obs;

  SmartFarmController({required this.repository});

  @override
  void onInit() {
    _loadChatHistory();
    super.onInit();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future<void> _loadChatHistory() async {
    isLoading.value = true;
    // Load from local storage
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (messages.isEmpty) {
      _addBotMessage('welcome'.tr);
    }
    isLoading.value = false;
  }

  void _addBotMessage(String text) {
    final message = MessageModel(
      id: const Uuid().v4(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    );
    messages.add(message);
    _scrollToBottom();
  }

  void addUserMessage(String text, {String? imagePath}) {
    if (text.isEmpty && imagePath == null) return;

    final message = MessageModel(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      imagePath: imagePath,
    );

    messages.add(message);
    textController.clear();
    _scrollToBottom();

    if (imagePath != null) {
      _analyzeImage(File(imagePath));
    } else {
      _getAIResponse(text);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _getAIResponse(String query) async {
    isAnalyzing.value = true;
    try {
      final response = await repository.getAIResponse(query);
      _addBotMessage(response);
    } catch (e) {
      _addBotMessage('general_message'.tr);
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    isAnalyzing.value = true;
    try {
      final response = await repository.analyzeImage(imageFile);
      _addBotMessage(response);
    } catch (e) {
      _addBotMessage('imageAnalysis'.tr);
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (image != null) {
      addUserMessage("", imagePath: image.path);
    }
  }

  void updateMessage(String messageId, String newText) {
    final index = messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final updatedMessage = messages[index].copyWith(text: newText);
      messages[index] = updatedMessage;
      
      // Regenerate AI response if it's a user message and not the last message
      if (updatedMessage.isUser && index < messages.length - 1) {
        _getAIResponse(newText);
      }
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    
    showSuccess(
       'copied'.tr,
    );
  }
}