import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../app/controller/app_controller.dart';
import '../../model/payables_receivables_model/payables_receivables_model.dart';

  final AppDataController appDeta = Get.put(AppDataController());
class PayablesReceivablesRepository {
  Future<PayablesReceivablesList> fetchPayablesReceivablesList() async {
    final farmerId = appDeta.userId;
    final url = Uri.parse(
      '${appDeta.baseUrl.value}/payables_receivables_list/$farmerId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return PayablesReceivablesList.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load payables and receivables');
    }
  }
}
