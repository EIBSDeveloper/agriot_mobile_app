import 'dart:convert';

import 'package:argiot/src/app/service/http/http_exception.dart';
import 'package:get/get.dart';
import '../../../controller/app_controller.dart';
import '../../../service/http/http_service.dart';
import '../../../service/utils/utils.dart';

class FarmerRepository {
  final HttpService _httpService = Get.find();
  final AppDataController appData = Get.find();

  final AppDataController appDeta = Get.put(AppDataController());
  Future<Map<String, dynamic>> editFarmer({
    required String name,
    String? phone,
    required String email,
    required String doorNo,
    required String pincode,
    required double latitude,
    required double longitude,
    String? description,
    String? img,
    required String companyName,
    required String taxNo,
  }) async {
    final userId = appDeta.farmerId;
    try {
      // Prepare the request body
      final body = {
        "name": name,
        if (phone != null) "phone": phone,
        "email": email,
        "door_no": doorNo,
        "pincode": pincode,
        "locations": generateGoogleMapsUrl(latitude, longitude),
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
