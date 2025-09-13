import 'dart:ui';

import 'package:argiot/src/app/modules/auth/model/get_otp.dart';
import 'package:get/get.dart';

class AppDataController extends GetxController {
  RxString userId = '297'.obs;
  RxString emailId = ''.obs;
  RxString username = ''.obs;

  Rx<Locale> appLanguage = const Locale('en', 'US').obs;
  RxString apiKey = 'eb0d8580a7a6e8a3a5f25a2d6b1366b8'.obs;
  RxString baseUrl = 'http://147.93.19.253:5000/Api'.obs;
  RxString baseUrlWithoutAPi = 'http://147.93.19.253:5000'.obs;
  Rx<GetOtp?> loginState = Rx<GetOtp?>(null);
  String weatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  String weatherApiKey = 'f0dd3d4a11a1446a7e29124d1911268b';
}
