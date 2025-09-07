// models/sales_model.dart

import 'dart:convert';
import 'package:argiot/src/app/modules/registration/model/dropdown_item.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

class AddDocumentRepository {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<AppDropdownItem>> getDocumentTypes() async {
    final response = await _httpService.get('/document_categories');
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => AppDropdownItem.fromJson(item))
        .toList();
  }
}
