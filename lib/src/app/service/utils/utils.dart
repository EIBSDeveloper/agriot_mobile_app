import 'dart:ui';

import 'package:argiot/src/app/modules/subscription/model/package_usage.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../controller/app_controller.dart';
import '../../controller/user_limit.dart';
import '../../modules/guideline/model/guideline.dart';
import '../../routes/app_routes.dart';
import 'enums.dart';

AppDataController appData = Get.find();

UserLimitController limitController = Get.put(UserLimitController());

double kelvinToCelsius(final double kelvin) => kelvin - 273.15;

String generateGoogleMapsUrl(double latitude, double longitude) =>
    "https://www.google.com/maps/place/Madurai,+Tamil+Nadu/@$latitude,$longitude";

String capitalizeFirstLetter(final String input) =>
    input.isEmpty ? input : input[0].toUpperCase() + input.substring(1);

String? getYoutubeThumbnailUrl(
  String? videoId, {
  String quality = 'hqdefault',
}) =>
    videoId == null ? null : 'https://img.youtube.com/vi/$videoId/$quality.jpg';

extension IterableUtils<E> on Iterable<E> {
  Iterable<T> whereMap<T>(T? Function(E e) transform) sync* {
    for (final e in this) {
      final result = transform(e);
      if (result != null) yield result;
    }
  }
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

Future<PackageUsage?> findLimit() async {
  await limitController.loadUsage();
  return limitController.packageUsage.value;
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

int getInventoryTypeId(InventoryTypes typeName) {
  switch (typeName) {
    case InventoryTypes.fuel:
      return 6;
    case InventoryTypes.vehicle:
      return 1;
    case InventoryTypes.machinery:
      return 2;
    case InventoryTypes.tools:
      return 3;
    case InventoryTypes.pesticides:
      return 4;
    case InventoryTypes.fertilizer:
      return 5;
    case InventoryTypes.seeds:
      return 7;
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

void handleGuidelineTap(Guideline guideline) {
  if (guideline.mediaType == 'video' && guideline.videoUrl != null) {
    openUrl(Uri.parse(guideline.videoUrl!)); // Open video player
  } else if (guideline.mediaType == 'document' && guideline.document != null) {
    Get.toNamed(
      Routes.docViewer,
      arguments: "${appData.baseUrlWithoutAPi}${guideline.document}",
    ); // Open document viewer
  } else {
    showError('Unable to open guideline content');
  }
}

int getDocTypeId(DocTypes type) {
  if (type == DocTypes.land) {
    return 0;
  } else if (type == DocTypes.expense) {
    return 1;
  } else if (type == DocTypes.sales) {
    return 2;
  } else if (type == DocTypes.inventory) {
    return 3;
  } else if (type == DocTypes.payouts) {
    return 4;
  }
  return 0;
}

Color getTaskColors(TaskTypes task) {
  switch (task) {
    case TaskTypes.completed:
      return const Color(0xFF4CAF50);
    case TaskTypes.waiting:
      return const Color(0xFFFFC107);
    case TaskTypes.pending:
      return const Color(0xFF2196F3);
    case TaskTypes.inProgress:
      return const Color(0xFF03A9F4);
    case TaskTypes.cancelled:
      return const Color(0xFFF44336);
    default:
      return const Color(0xFF9E9E9E);
  }
}

TaskTypes getTaskStatus(int task) {
  switch (task) {
    case 1:
      return TaskTypes.waiting;
    case 2:
      return TaskTypes.completed;
    case 3:
      return TaskTypes.inProgress;
    case 4:
      return TaskTypes.pending;
    case 5:
      return TaskTypes.cancelled;
    default:
      return TaskTypes.all;
  }
}

DocTypes getDocumentTypes(int task) {
  switch (task) {
    case 1:
      return DocTypes.expense;
    case 2:
      return DocTypes.sales;
    case 3:
      return DocTypes.inventory;
    case 4:
      return DocTypes.payouts;
    default:
      return DocTypes.land;
  }
}

int getTaskId(TaskTypes task) {
  switch (task) {
    case TaskTypes.waiting:
      return 1;
    case TaskTypes.completed:
      return 2;
    case TaskTypes.inProgress:
      return 3;
    case TaskTypes.pending:
      return 4;
    case TaskTypes.cancelled:
      return 5;
    default:
      return 0;
  }
}

String getTaskName(TaskTypes task) {
  switch (task) {
    case TaskTypes.waiting:
      return "Waiting";
    case TaskTypes.completed:
      return "Completed";
    case TaskTypes.inProgress:
      return "In Progress";
    case TaskTypes.pending:
      return "Pending";
    case TaskTypes.cancelled:
      return "Cancelled";
    default:
      return "All";
  }
}
