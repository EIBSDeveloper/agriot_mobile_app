// lib/modules/expenses/models/expense_model.dart

import 'dart:convert';
import 'package:argiot/src/app/modules/expense/expense_model.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:get/get.dart';

import '../task/model/model.dart';

class ExpenseRepository {
  final HttpService _httpService = Get.find<HttpService>();

  final AppDataController _appDataController = Get.find();
  Future<TotalExpense> getTotalExpense(String timePeriod) async {
    final farmerId = _appDataController.userId.value;
    try {
      final response = await _httpService.post(
        '/total_expense_and_purchase/$farmerId/',
        {'time_period': timePeriod},
      );
      return TotalExpense.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to load total expense: $e');
    }
  }

  Future<List<CropModel>> getCropList() async {
    final farmerId = _appDataController.userId;
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

  Future<ExpenseResponse> getExpenses(String timePeriod) async {
    final farmerId = _appDataController.userId.value;
    try {
      final response = await _httpService.post(
        '/both_farmer_expense_purchase_list/$farmerId/',
        {'time_period': timePeriod},
      );
      return ExpenseResponse.fromJson(json.decode(response.body));
    } catch (e) {
      throw Exception('Failed to load expenses: $e');
    }
  }

  Future<List<Chart>> getExpenseSummary(String timePeriod) async {
    final farmerId = _appDataController.userId.value;
    try {
      final response = await _httpService.post('/expense-totals/', {
        'farmer_id': farmerId,
        'time_period': timePeriod,
      });
      return List<Chart>.from(
        json.decode(response.body).map((x) => Chart.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to load expense summary: $e');
    }
  }

  Future<List<ExpenseType>> getExpenseTypes() async {
    try {
      final response = await _httpService.get('/expenses');
      var decode = json.decode(response.body);
      return List<ExpenseType>.from(decode.map((x) => ExpenseType.fromJson(x)));
    } catch (e) {
      throw Exception('Failed to load expense types: $e');
    }
  }

  Future<List<FileType>> getFileTypes() async {
    try {
      final response = await _httpService.get('/document_categories');
      return List<FileType>.from(
        json.decode(response.body)['data'].map((x) => FileType.fromJson(x)),
      );
    } catch (e) {
      throw Exception('Failed to load file types: $e');
    }
  }

  Future addExpense(
    int myCrop,
    double amount,
    int typeExpenses,
    String createdDay,
    String description, {
    List<Map<String, dynamic>>? documents,
  }) async {
    final farmerId = _appDataController.userId;
    try {
      final response = await _httpService.post('/add_expense/$farmerId', {
        'my_crop': myCrop,
        'amount': amount,
        'type_expenses': typeExpenses,
        'created_day': createdDay,
        'description': description,
        if (documents != null) 'document': documents,
      });
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }
}
