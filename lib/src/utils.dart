import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'app/controller/user_limit.dart';
import 'app/modules/subscription/package_model.dart';
import 'routes/app_routes.dart';

void showError(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
  );
}

void showSuccess(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.green,
    textColor: Colors.white,
  );
}

void warningSuccess(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.orangeAccent,
    textColor: Colors.white,
  );
}

double kelvinToCelsius(double kelvin) {
  return kelvin - 273.15;
}

PackageUsage? findLimit() {
  UserLimitController limitController = Get.find();
  return limitController.packageUsage.value;
}

packageRefresh() {
  UserLimitController limitController = Get.find();
  limitController.loadUsage();
}

void showDefaultGetXDialog(String message) {
  Get.defaultDialog(
    title: "Package Limit Reached",
    middleText: "You've reached your limit for adding new $message .",
    textConfirm: "Upgrade",
    textCancel: "Close",
    radius :10.0,
    onConfirm: () {
      Get.toNamed(Routes.subscriptionUsage);
    },
    onCancel: () {
      Get.back();
    },
  );
}
