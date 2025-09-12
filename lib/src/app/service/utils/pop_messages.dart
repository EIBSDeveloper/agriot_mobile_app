import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

void showError(final String message) {
  if (message.contains('404') ||
      message.contains('500') ||
      message.contains('load') ||
      message.contains('error') ||
      message.contains('Error')) {
    return;
  }
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
  );
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

void showWarning(final String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.orangeAccent,
    textColor: Colors.white,
  );
}
void showDefaultGetXDialog(final String message) {
  Get.defaultDialog(
    title: 'Package Limit Reached',
    middleText: "You've reached your limit for adding new $message .",
    textConfirm: "Upgrade",
    textCancel: 'Close',
    radius: 10,
    onConfirm: () {
      Get.back();
      Get.toNamed(Routes.subscriptionUsage);
    },
    onCancel: Get.back,
  );
}
