import 'dart:convert';

import 'package:argiot/src/payable/model/model_pay_receive/pay_receivemodel.dart';
import 'package:http/http.dart' as http;

import '../customer_add_repository/customer_add_repository.dart';

class CustomerlistRepository {
  //customer payables
  Future<List<Customerlistmodel>> fetchCustomerPayableslist() async {
    final farmerId = appDeta.userId;
    final url = Uri.parse(
      '${appDeta.baseUrl.value}/customer_payables_list/$farmerId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonBody = json.decode(response.body);
      return jsonBody.map((e) => Customerlistmodel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load customer payables");
    }
  }

  //customer receivables
  Future<List<Customerlistmodel>> fetchCustomerReceivableslist() async {
    final farmerId = appDeta.userId;
    final url = Uri.parse(
      "${appDeta.baseUrl.value}/customer_receivables_list/$farmerId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonBody = json.decode(response.body);
      return jsonBody.map((e) => Customerlistmodel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load customer receivables");
    }
  }

  //Vendor payables
  Future<List<Customerlistmodel>> fetchVendorPayableslist() async {
    final farmerId = appDeta.userId;
    final url = Uri.parse(
      "${appDeta.baseUrl.value}/vendors_payables_list/$farmerId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonBody = json.decode(response.body);
      return jsonBody.map((e) => Customerlistmodel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load vendor payables");
    }
  }

  //Vendor Receivables
  Future<List<Customerlistmodel>> fetchVendorReceivableslist() async {
    final farmerId = appDeta.userId;
    final url = Uri.parse(
      "${appDeta.baseUrl.value}/vendors_receivables_list/$farmerId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonBody = json.decode(response.body);
      return jsonBody.map((e) => Customerlistmodel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load vendor receivables");
    }
  }
}
