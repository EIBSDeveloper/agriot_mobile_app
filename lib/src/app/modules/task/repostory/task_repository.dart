import 'package:argiot/src/app/modules/task/model/activity_model.dart';
import 'package:argiot/src/app/modules/task/model/crop_model.dart';
import 'package:argiot/src/app/modules/task/model/task_details.dart';
import 'package:argiot/src/app/modules/task/model/task_group.dart';
import 'package:argiot/src/app/modules/task/model/task_request.dart';
import 'package:argiot/src/app/modules/task/model/task_response.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
import '../../../service/utils/enums.dart';
import '../../near_me/model/models.dart';

class TaskRepository {
  final HttpService _httpService = Get.put(HttpService());
  final AppDataController _appDataController = Get.find();
  Future<LandList> getLands() async {
    final userId = _appDataController.farmerId;
    final response = await _httpService.get('/lands/$userId');
    return LandList.fromJson(json.decode(response.body));
  }

  Future<TaskResponse> fetchTasks({
    required String landId,
    required int month,
  }) async {
    final farmerId = _appDataController.farmerId;
    try {
      final response = await _httpService.get(
        '/task_year_list/$farmerId?land_id=$landId&month=$month',
      );
      return TaskResponse.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateTask({
    required int id,
    required int myCrop,
    required DateTime startDate,
    required String description,
    required int scheduleStatus,
  }) async {
    final farmerId = _appDataController.farmerId.value;
    try {
      final response = await _httpService.put('/edit_task/$farmerId', {
        'id': id,
        'my_crop': myCrop,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'description': description,
        'schedule_status': scheduleStatus,
      });
      return json.decode(response.body);
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
      throw Exception('Failed to load activity types: ${e.toString()}');
    }
  }

  Future<List<CropModel>> getCropList() async {
    final farmerId = _appDataController.farmerId;
    try {
      final response = await _httpService.get(
        '/land-and-crop-details/$farmerId',
      );
      final lands = json.decode(response.body)['lands'] as List;

      final allCrops = lands
          .expand((land) => land['crops'] as List)
          .map((crop) => CropModel.fromJson(crop))
          .toSet()
          .toList();

      return allCrops;
    } catch (e) {
      throw Exception('Failed to load crops: ${e.toString()}');
    }
  }

  String getCurrentMonth(month) {
    const monthAbbreviations = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthAbbreviations[month - 1];
  }

  Future<List<TaskGroup>> getTaskList({
    required int landId,
    required int month,
  }) async {
    String monthName = getCurrentMonth(month);

    // If no cache or force refresh, fetch from network
    final response = await _httpService.get(
      '/get_task_list/${_appDataController.farmerId}?land_id=$landId&month=$monthName',
    );

    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((item) => TaskGroup.fromJson(item)).toList();
  }

  Future<void> addTask(TaskRequest taskRequest) async {
    await _httpService.post('/new_task/', taskRequest.toJson());
  }

  Future<void> editTask(Map<String, dynamic> taskRequest) async {
    final farmerId = _appDataController.farmerId;
    await _httpService.put('/edit_task/$farmerId', jsonEncode(taskRequest));
  }

  Future<void> deleteTask(int taskId) async {
    final farmerId = _appDataController.farmerId;
    await _httpService.post('/deactivate-my-schedule/$farmerId/', {
      'id': taskId,
    });
  }

  Future<TaskDetails> getTaskDetails(int taskId) async {
    final farmerId = _appDataController.farmerId;
    try {
      final response = await _httpService.get(
        '/get_schedule_details/$farmerId/?id=$taskId',
      );
      return TaskDetails.fromJson(json.decode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addComment(int taskId, String comment) async {
    final farmerId = _appDataController.farmerId;
    try {
      await _httpService.put('/add_comments/$farmerId', {
        'id': taskId,
        'comment': comment,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markTaskCompleted(
    int taskId,
    int cropId,
    String startDate,
    String description,
    TaskTypes scheduleStatus,
  ) async {
    final farmerId = _appDataController.farmerId;
    try {
      final inputFormat = DateFormat('dd-MM-yyyy');
      final dateTime = inputFormat.parse(startDate);

      final outputFormat = DateFormat('yyyy-MM-dd');
      final formattedDate = outputFormat.format(dateTime);

      await _httpService.put('/edit_task/$farmerId', {
        'id': taskId,
        'my_crop': cropId,
        'start_date': formattedDate,
        'description': description,
        'schedule_status': getTaskId(scheduleStatus),
        'schedule_choice': 0,
      });
    } catch (e) {
      rethrow;
    }
  }
}
