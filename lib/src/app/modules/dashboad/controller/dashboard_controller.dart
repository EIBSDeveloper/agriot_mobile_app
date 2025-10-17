import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/dashboad/model/finance_data.dart';
import 'package:argiot/src/app/modules/dashboad/model/land_v_s_crop_model.dart';
import 'package:argiot/src/app/modules/dashboad/model/market_price.dart';
import 'package:argiot/src/app/modules/dashboad/model/payment_summary.dart';
import 'package:argiot/src/app/modules/dashboad/model/weather_data.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../controller/user_limit.dart';
import '../../guideline/model/guideline.dart';
import '../../near_me/model/models.dart';
import '../../task/model/task.dart';

import '../model/widget_config.dart';
import '../repostory/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = Get.find();
  final AppDataController appDeta = Get.find();
  final UserLimitController userLimit = Get.find();
  var selectedLand = Land(id: 0, name: '').obs;
  var lands = <Land>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool idlandVSCropGraph = true.obs;

  // Data observables
  final Rx<WeatherData?> weatherData = Rx<WeatherData?>(null);
  final RxList<Guideline> guidelines = <Guideline>[].obs;
  final RxList<Task> tasks = <Task>[].obs;
  final Rx<FinanceData?> financeData = Rx<FinanceData?>(null);
  final Rx<Position?> position = Rx<Position?>(null);

  final Rx<LandVSCropModel?> landVSCropData = Rx<LandVSCropModel?>(null);

  final RxList<MarketPrice> marketPrices = <MarketPrice>[].obs;

  final Rx<PaymentSummary?> paymentSummary = Rx<PaymentSummary?>(null);
  final Rx<WidgetConfig> widgetConfig = WidgetConfig(
    weatherAndPayments: true,
    expensesSales: true,
    marketPrice: true,
    scheduleTask: true,
    guidelines: true,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    fetchLands();
  }

  Future<void> fetchLands() async {
    try {
      isLoading(true);
      final landList = await _repository.getLands();
      lands.assignAll(landList.lands);
      if (lands.isNotEmpty) {
        selectedLand.value = lands.first;
        loadInitialData();
        userLimit.loadUsage();
      }
    } catch (w) {
      isLoading(false);
    }
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;

      // Load widget configuration
      widgetConfig.value = await _repository.getWidgetConfig();
      if (position.value == null) {
        position.value = await Geolocator.getCurrentPosition();
      }
      await loadData();

      fetchWeatherData(position.value!.latitude, position.value!.longitude);
    } catch (e) {
      showError('Failed to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      if (widgetConfig.value.weatherAndPayments) {
        await fetchPaymentSummary();
      }

      if (widgetConfig.value.expensesSales) {
        await fetchFinanceData();
      }

      if (widgetConfig.value.marketPrice) {
        await fetchMarketPrices();
      }

      if (widgetConfig.value.scheduleTask) {
        await fetchTasks();
      }

      if (widgetConfig.value.guidelines!) {
        await fetchGuidelines();
      }
      fetchWeatherData(position.value!.latitude, position.value!.longitude);
    } catch (e) {
      showError('Failed to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeatherData(double lat, double lon) async {
    weatherData.value = await _repository.getWeatherData(lat, lon);
  }

  Future<void> fetchGuidelines() async {
    guidelines.value = await _repository.getGuidelines();
  }

  Future<void> fetchTasks() async {
    if (selectedLand.value.id > 0) {
      tasks.value = await _repository.getTasks(selectedLand.value.id);
    }
  }

  Future<void> fetchFinanceData() async {
    if (selectedLand.value.id > 0) {
      financeData.value = await _repository.getMonthlyFinanceData(
        selectedLand.value.id,
      );
      idlandVSCropGraph.value =
          (financeData.value?.totalExpenses == 0 &&
          financeData.value?.totalSales == 0);
      landVSCropData.value = await _repository.getLandVSCropData();
    }
  }

  Future<void> fetchMarketPrices() async {
    if (selectedLand.value.id > 0) {
      marketPrices.value = await _repository.getMarketPrices(
        selectedLand.value.id,
      );
    }
  }

  Future<void> fetchPaymentSummary() async {
    paymentSummary.value = await _repository.getPaymentSummary();
  }



  Future<void> updateWidgetConfiguration(WidgetConfig newConfig) async {
    try {
      isLoading.value = true;
      final success = await _repository.updateWidgetConfig(newConfig);
      if (success) {
        widgetConfig.value = newConfig;
        await loadInitialData();
      }
    } catch (e) {
      showError('Failed to update widget configuration');
    } finally {
      isLoading.value = false;
    }
  }

  void changeLand(landId) {
    selectedLand.value = landId;
    loadData();
  }
}
