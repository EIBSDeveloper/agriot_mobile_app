import 'dart:convert';
import 'dart:ui';

import 'package:argiot/src/app/modules/auth/model/get_otp.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../modules/manager/model/manager_permission.dart';

class AppDataController extends GetxController {
  RxString farmerId = '120'.obs;
  RxBool isManager = false.obs;
  RxString managerID = ''.obs;
  RxString emailId = ''.obs;
  RxString username = ''.obs;
  Rx<ManagerPermission?> permission = Rx<ManagerPermission?>(null);

  Rx<GetOtp?> loginState = Rx<GetOtp?>(null);
  Rx<Locale> appLanguage = const Locale('en', 'US').obs;
  RxString apiKey = 'eb0d8580a7a6e8a3a5f25a2d6b1366b8'.obs;
  RxString baseUrl = 'https://dev.agriotwifarm.com/Api'.obs;
  RxString baseUrlWithoutAPi = 'https://dev.agriotwifarm.com'.obs;
  String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  String weatherApiKey = 'f0dd3d4a11a1446a7e29124d1911268b';

  @override
  void onInit() {
    super.onInit();

    ever(managerID, (String id) {
      if (id != '0'&&id != '') {
        getManagerPermission();
      }
    });
  }

  Future<void> getManagerPermission() async {
    final url = Uri.parse(baseUrl + "/manager_permissions/${managerID.value}");
    final response = await http.get(url);
    permission.value = ManagerPermission.fromJson(json.decode(response.body));
  }
}
