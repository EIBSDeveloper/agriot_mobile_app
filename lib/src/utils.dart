import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app/controller/user_limit.dart';
import 'app/modules/subscription/package_model.dart';
import 'routes/app_routes.dart';

void showError(final String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
  );
}
String capitalizeFirstLetter(final String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}


  Future<void> makePhoneCall(final String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

void showSuccess(final String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.green,
    textColor: Colors.white,
  );
}

void warningSuccess(final String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.orangeAccent,
    textColor: Colors.white,
  );
}

double kelvinToCelsius(final double kelvin) {
  return kelvin - 273.15;
}

PackageUsage? findLimit() {
  UserLimitController limitController = Get.put(UserLimitController());
  return limitController.packageUsage.value;
}

packageRefresh() {
  UserLimitController limitController = Get.put(UserLimitController());
  limitController.loadUsage();
}

 void showDefaultGetXDialog(final String message) {
  Get.defaultDialog(
    title: 'Package Limit Reached',
    middleText: "You've reached your limit for adding new $message .",
    textConfirm: "Upgrade",
    textCancel: 'Close',
    radius :10,
    onConfirm: () async {
      await Get.toNamed(Routes.subscriptionUsage);
    },
    onCancel: Get.back,
  );
}
