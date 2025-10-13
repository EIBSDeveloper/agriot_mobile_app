import 'dart:io';

import 'package:argiot/src/chat_service.dart';
import 'package:argiot/src/detection_service.dart';
import 'package:get/get.dart';


class ChatRepository extends GetxService {
  
  final GeminiApiService geminiService =GeminiApiService();
  final VisionApiService visionService =VisionApiService();


  Future<String> getAIResponse(String query) async {
    try {
      return await geminiService.getResponse(query);
    } catch (e) {
      throw Exception('Failed to get AI response');
    }
  }

  Future<String> analyzeImage(File imageFile) async {
    try {
      final analysisData = await visionService.detectCropCondition(imageFile);
      return await geminiService.getResponse(
        "Analyze this plant/crop and provide farming advice. If there are any signs of disease, explain what the disease is and recommend treatment.",
        contextData: analysisData,
      );
    } catch (e) {
      throw Exception('Failed to analyze image');
    }
  }
}