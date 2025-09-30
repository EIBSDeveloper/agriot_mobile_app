import 'dart:convert';
import 'package:argiot/src/app/modules/task/model/schedule.dart';
import 'package:argiot/src/app/modules/task/model/schedule_land.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/task/model/activity_model.dart';
import 'package:argiot/src/app/modules/task/model/task_request.dart';
import 'package:argiot/src/app/service/http/http_service.dart';
import 'package:get/get.dart';

class ScheduleRepository {
  final HttpService _httpService = Get.find<HttpService>();
  final AppDataController appDeta = Get.put(AppDataController());
  Future<List<Schedule>> fetchSchedules(int landId, int cropId) async {
    try {
      final String farmerId = appDeta.farmerId.value;
      final response = await _httpService.get(
        '/best_practice_schedule/$farmerId/$landId/$cropId/',
      );

      if (response.statusCode == 200) {
        final List<dynamic> schedulesJson = json.decode(
          response.body,
        )['schedules'];
        return schedulesJson.map((json) => Schedule.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load schedules');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Schedule> fetchScheduleDetails(
    int landId,
    int cropId,
    int scheduleId,
  ) async {
    try {
      final farmerId = appDeta.farmerId;
      final response = await _httpService.get(
        '/best_practice_schedule/$farmerId/$landId/$cropId/$scheduleId',
      );

      if (response.statusCode == 200) {
        final schedulesJson = json.decode(response.body)["schedule"];
        if (schedulesJson.isNotEmpty) {
          return Schedule.fromJson(schedulesJson);
        } else {
          throw Exception('Schedule not found');
        }
      } else {
        throw Exception('Failed to load schedule details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ActivityModel>> getActivityTypes() async {
    try {
      final response = await _httpService.get('/schedule_activity_types');
      final data = json.decode(response.body)['data'] as List;
      return data.map((item) => ActivityModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load activity types: $e');
    }
  }

  Future<void> addTask(TaskRequest taskRequest) async {
    await _httpService.post('/new_task/', taskRequest.toJson());
  }

  Future<List<ScheduleLand>> fetchLandsAndCrops() async {
    final farmerId = appDeta.farmerId.value;
    try {
      final response = await _httpService.get(
        '/land-and-crop-details/$farmerId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> landsJson = json.decode(response.body)['lands'];
        return landsJson.map((json) => ScheduleLand.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lands and crops');
      }
    } catch (e) {
      rethrow;
    }
  }
}
