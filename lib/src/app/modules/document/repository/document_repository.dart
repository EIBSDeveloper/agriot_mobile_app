import 'dart:convert';
import 'package:get/get.dart';

import '../../../service/http/http_service.dart';
import '../../registration/model/dropdown_item.dart';

class DocumentRepository {
  final HttpService _httpService = Get.find<HttpService>();

  Future<List<AppDropdownItem>> getDocumentTypes() async {
    final response = await _httpService.get('/document_categories');
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List)
        .map((item) => AppDropdownItem.fromJson(item))
        .toList();
  }
}
