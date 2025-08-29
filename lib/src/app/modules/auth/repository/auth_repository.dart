import 'dart:convert';

import 'package:get/get.dart';

import '../../../utils/http/http_service.dart';
import '../model/auth_model.dart';
import '../model/otp.dart';

class AuthRepository {
  final HttpService _httpService = Get.find();

  Future<GetOtp> loginWithMobile(String mobileNumber, bool value) async {
    var body = {
      if (!value) 'mobile_number': mobileNumber,
      if (value) 'email': mobileNumber,
      'name': 'user',
      "google_login":false
    };
    final response = await _httpService.post('/get_otp', body);

    var jsonDecode2 = jsonDecode(response.body);

    return GetOtp.fromJson(jsonDecode2);
  }

  Future verifyOtp(String mobileNumber, String otp, bool value) async {
    final response = await _httpService.post("/verify-otp/", {
    if (!value) 'mobile_number': mobileNumber,
      if (value) 'email': mobileNumber,
      'otp': int.parse(otp),
    });

    VerifyOtp authResponse = VerifyOtp.fromJson(jsonDecode(response.body));

    return authResponse;
  }
}
