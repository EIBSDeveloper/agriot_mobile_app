import 'dart:convert';
import 'package:argiot/src/app/modules/forming/model/crop_overview.dart';
import 'package:argiot/src/app/modules/forming/model/my_crop_details.dart';
import 'package:argiot/src/app/modules/task/model/task_group.dart';
import 'package:argiot/src/app/modules/task/model/task_response.dart';
import 'package:get/get.dart';
import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
import '../model/land.dart';

class FormingRepository {
  final HttpService _httpService = Get.find();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<List<Land>> getLandsWithCrops() async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get('/land-and-crop-details/$userId');
    final jsonData = json.decode(response.body);
    return List<Land>.from(jsonData['lands'].map((x) => Land.fromJson(x)));
  }

  Future<Map<String, dynamic>> getLandDetails(int landId) async {
    final userId = appDeta.farmerId;
    final response = await _httpService.get(
      '/land_details_with_crop/$userId?land_id=$landId',
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> daleteLandDetails(int landId) async {
    final userId = appDeta.farmerId;
    final response = await _httpService.post('/deactivate_my_land/$userId/', {
      "id": landId,
    });
    return json.decode(response.body);
  }

  Future<void> deleteTask(int taskId) async {
    final farmerId = appDeta.farmerId;
    await _httpService.post('/deactivate-my-schedule/$farmerId/', {
      'id': taskId,
    });
  }

  Future<void> deleteCrop(int taskId) async {
    final farmerId = appDeta.farmerId;
    await _httpService.post('/delete_crop/$farmerId/', {
      'id': taskId,
    });
  }

  Future<CropOverview> getCropOverview(int landId, int cropId) async {
    final farmerId = appDeta.farmerId;
    try {
      final response = await _httpService.post('/crop_details_land/$farmerId', {
        'land_id': landId,
        'crop_id': cropId,
      });
      var decode = json.decode(response.body);
      return CropOverview.fromJson(decode);
    } catch (e) {
      throw Exception('Failed to load crop overview: $e');
    }
  }

  Future<MyCropDetails> getCropDetails(int landId, int cropId) async {
    final farmerId = appDeta.farmerId;
    try {
      final response = await _httpService.get(
        '/crop_view/$farmerId/$landId/$cropId',
      );
      var cropDetails = MyCropDetails.fromJson(json.decode(response.body));
      return cropDetails;
    } catch (e) {
      throw Exception('Failed to load crop details: $e');
    }
  }

  Future<void> updateCropDetails(Map<String, dynamic> data) async {
    final farmerId = appDeta.farmerId;
    try {
      var data2 = data['farmer'] = farmerId;
      await _httpService.post('/edit_my_land/$farmerId', data2);
    } catch (e) {
      throw Exception('Failed to update crop details: $e');
    }
  }

  Future<List<TaskGroup>> getTaskList({
    required int landId,
    required DateTime month,
    required int cropId,
  }) async {
    // If no cache or force refresh, fetch from network
    final response = await _httpService.get(
      '/tasks_list/for-month-and-crop/${appDeta.farmerId.value}?land_id=$landId&crop_id=$cropId&month=${month.month}&year=${month.year}',
    );

    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((item) => TaskGroup.fromJson(item)).toList();
  }

  Future<TaskResponse> fetchTasks({
    required String landId,
    required DateTime month,
    required int cropId,
  }) async {
    try {
      final response = await _httpService.get(
        '/tasks/for-month-and-crop/${appDeta.farmerId.value}?land_id=$landId&crop_id=$cropId&month=${month.month}&year=${month.year}',
      );
      return TaskResponse.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }
}
