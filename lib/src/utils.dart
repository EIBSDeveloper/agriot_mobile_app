import 'dart:ui';

import 'package:argiot/src/app/modules/subscription/model/package_usage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'app/controller/user_limit.dart';
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

Future<void> openUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
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

double kelvinToCelsius(final double kelvin) => kelvin - 273.15;

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

String getType(int id) {
  if (id == 6) {
    return 'fuel';
  } else if (id == 1) {
    return 'vehicle';
  } else if (id == 2) {
    return 'machinery';
  } else if (id == 3) {
    return 'tools';
  } else if (id == 4) {
    return 'Pesticides';
  } else if (id == 5) {
    return 'fertilizers';
  } else if (id == 7) {
    return 'seeds';
  }
  return 'fuel';
}
  int getInventoryTypeId(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'fuel':
        return 6;
      case 'vehicle':
        return 1;
      case 'machinery':
        return 2;
      case 'tools':
        return 3;
      case 'pesticides':
        return 4;
      case 'fertilizers':
        return 5;
      case 'seeds':
        return 7;
      default:
        return 0;
    }
  }

  Future<Uint8List> getBytesFromUrl(String url, {int width = 100}) async {
  final http.Response response = await http.get(Uri.parse(url));
  final Uint8List bytes = response.bodyBytes;
  final codec = await instantiateImageCodec(bytes, targetWidth: width);
  final frameInfo = await codec.getNextFrame();
  final byteData = await frameInfo.image.toByteData(
    format: ImageByteFormat.png,
  );
  return byteData!.buffer.asUint8List();
}


  String getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }