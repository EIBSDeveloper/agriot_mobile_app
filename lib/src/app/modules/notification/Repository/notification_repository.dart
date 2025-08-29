// notification_repository.dart
import 'dart:convert';

import 'package:get/get.dart';

import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';
import '../notification_model.dart';

class NotificationRepository {
  final HttpService _httpService = Get.find();

  final AppDataController _appDataController = Get.find();
  Future<List<NotificationModel>> getNotifications() async {
    final userId = _appDataController.userId;
    try {
      final response = await _httpService.get('/get_notifications_by_farmer/$userId');
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => NotificationModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: ${e.toString()}');
    }
  }
}