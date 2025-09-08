import 'dart:convert';
import 'package:argiot/src/app/modules/dashboad/model/finance_data.dart';
import 'package:argiot/src/app/modules/dashboad/model/guideline.dart';
import 'package:argiot/src/app/modules/dashboad/model/land_v_s_crop_model.dart';
import 'package:argiot/src/app/modules/dashboad/model/market_price.dart';
import 'package:argiot/src/app/modules/dashboad/model/payment_summary.dart';
import 'package:argiot/src/app/modules/dashboad/model/weather_data.dart';
import 'package:get/get.dart';
import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
import '../../near_me/model/models.dart';
import '../model/task.dart';
import '../model/widget_config.dart';

class DashboardRepository {
  final HttpService _httpService = Get.find();
  final AppDataController _appDataController = Get.find();

  Future<WeatherData> getWeatherData(double lat, double lon) async {
    var weatherBaseUrllatlatlonlonappidweatherApiKey =
        '${_appDataController.weatherBaseUrl}?lat=$lat&lon=$lon&appid=${_appDataController.weatherApiKey}';
    final response = await _httpService.getRaw(
      weatherBaseUrllatlatlonlonappidweatherApiKey,
    );
    return WeatherData.fromJson(json.decode(response.body));
  }

  Future<List<Guideline>> getGuidelines() async {
    final response = await _httpService.post('/get_guidelines', {});
    final data = json.decode(response.body);
    return List<Guideline>.from(
      data['guidelines']?.map((x) => Guideline.fromJson(x)) ?? [],
    );
  }

  Future<List<DashBoardSchedule>> getTasks(int landId) async {
    final userId = _appDataController.userId;
    final response = await _httpService.get(
      '/dashboard_task_list/$userId/?land_id=$landId',
    );
    final data = json.decode(response.body);
    return List<DashBoardSchedule>.from(
      data['schedules']?.map((x) => DashBoardSchedule.fromJson(x)) ?? [],
    );
  }

  Future<FinanceData> getMonthlyFinanceData(int landId) async {
    final userId = _appDataController.userId;
    final response = await _httpService.get(
      '/monthly_sales_expenses/$userId/?land_id=$landId',
    );
    return FinanceData.fromJson(json.decode(response.body));
  }

  Future<LandVSCropModel> getLandVSCropData() async {
    final userId = _appDataController.userId;
    final response = await _httpService.get('/land-vs-crop-chart/$userId');
    return LandVSCropModel.fromJson(json.decode(response.body));
  }

  Future<List<MarketPrice>> getMarketPrices(int landId) async {
    final userId = _appDataController.userId;
    final response = await _httpService.get(
      '/get_product_market_report/$userId/?land_id=$landId',
    );
    final data = json.decode(response.body);

    final list = data is List ? data : data['results'] ?? [];

    return List<MarketPrice>.from(list.map((x) => MarketPrice.fromJson(x)));
  }

  Future<PaymentSummary> getPaymentSummary() async {
    final userId = _appDataController.userId;
    final response = await _httpService.get(
      '/payables_receivables_count/$userId',
    );
    return PaymentSummary.fromJson(json.decode(response.body));
  }

  Future<LandList> getLands() async {
    final userId = _appDataController.userId;
    final response = await _httpService.get('/lands/$userId');
    return LandList.fromJson(json.decode(response.body));
  }

  Future<void> deleteTask(int taskId) async {
    final farmerId = _appDataController.userId;
    await _httpService.post('/deactivate-my-schedule/$farmerId/', {
      'id': taskId,
    });
  }

  Future<WidgetConfig> getWidgetConfig() async {
    final userId = _appDataController.userId;
    final response = await _httpService.get('/widget_config/$userId');
    return WidgetConfig.fromJson(json.decode(response.body));
  }

  Future<bool> updateWidgetConfig(WidgetConfig config) async {
    final userId = _appDataController.userId;
    final response = await _httpService.put(
      '/update_widget_config/$userId',
      config.toJson(),
    );
    return json.decode(response.body)['success'] == true;
  }
}
