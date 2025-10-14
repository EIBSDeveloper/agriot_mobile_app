import 'dart:convert';

import 'package:argiot/src/app/modules/auth/model/get_otp.dart';
import 'package:argiot/src/app/modules/auth/model/verify_otp.dart';
import 'package:get/get.dart';

import '../../../service/http/http_service.dart';

class AuthRepository {
  final HttpService _httpService = Get.find();

  Future<GetOtp> loginWithMobile(
    String mobileNumber,
    bool value, {
    isGoogleLogin = false,
  }) async {
      dynamic  response ;
    try {
      var body = {
        if (!value) 'mobile_number': mobileNumber,
        if (value) 'email': mobileNumber,
        'name': 'user',
        if (value) "google_login": isGoogleLogin,
      };
      final response = await _httpService.post('/get_otp', body);

      var jsonDecode2 = jsonDecode(response.body);

      return GetOtp.fromJson(jsonDecode2);
    } catch (e) {
      //
      throw Exception(response?.body["details"]??"This Farmer is Inactive.");
    }
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
