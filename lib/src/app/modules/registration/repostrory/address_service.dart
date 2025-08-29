import 'dart:convert';

import 'package:get/get.dart';
import '../../../controller/app_controller.dart';
import '../../../utils/http/http_service.dart';

class FarmerRepository {
  final HttpService _httpService = Get.find();
  final AppDataController appData = Get.find();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<Map<String, dynamic>> editFarmer({
    required String name,
    String? phone,
    required String email,
    required int country,
    required int state,
    required int city,
    required int taluk,
    required int village,
    required String doorNo,
    required String pincode,
    String? description,
    String? img,
    required String companyName,
    required String taxNo,
  }) async {
    final userId = appDeta.userId;
    try {
      // Prepare the request body
      final body = {
        "name": name,
        if (phone != null) "phone": phone,
        "email": email,
        "country": country,
        "state": state,
        "city": city,
        "taluk": taluk,
        "village": village,
        "door_no": doorNo,
        "pincode": pincode,
        "description": description ?? '',
        if (img != null) "img": img,
        "company_name": companyName,
        "tax_no": taxNo,
      };

      // Make the PUT request
      final response = await _httpService.put('/edit_farmer/$userId', body);

      // Parse and return the response
      return json.decode(response.body);
    } catch (e) {
      // Handle any errors
      throw HttpException(message: 'Failed to edit farmer: ${e.toString()}');
    }
  }
}
