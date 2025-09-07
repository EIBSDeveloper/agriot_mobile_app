import 'dart:convert';
import 'package:argiot/src/app/modules/guideline/model/guideline.dart';
import 'package:argiot/src/app/modules/guideline/model/guideline_category.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

class GuidelineRepository {
  final HttpService _httpService = Get.put(HttpService());

  Future<List<Guideline>> getGuidelinesList(int guidelinestypeId) async {
    try {
      final response = await _httpService.post('/get_guidelines_list', {
        'guidelinestype_id': guidelinestypeId,
      });

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return (body as List).map((item) => Guideline.fromJson(item)).toList();
      }
      throw Exception('Failed to load guidelines list');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Guideline>> searchGuidelines(String query) async {
    try {
      final response = await _httpService.post('/guidelines_filter', {
        'filter': query,
      });

      // For http package Response
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return (responseBody as List)
            .map((item) => Guideline.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to search guidelines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching guidelines: $e');
    }
  }

  Future<List<GuidelineCategory>> getGuidelineCategories() async {
    try {
      final response = await _httpService.get('/guidelines_categories');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body)['data'];
        return (body as List)
            .map((item) => GuidelineCategory.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load guideline categories');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
