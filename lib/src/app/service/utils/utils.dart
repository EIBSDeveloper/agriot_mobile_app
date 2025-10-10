import 'dart:ui';

import 'package:argiot/src/app/modules/subscription/model/package_usage.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      arguments: "${guideline.document}",
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

extension RoleTypeExtension on RoleType {
  String get name {
    switch (this) {
      case RoleType.employee:
        return 'Employee';
      case RoleType.subAdmin:
        return 'Sub Admin';
      case RoleType.manager:
        return 'Manager';
    }
  }

  int get id {
    switch (this) {
      case RoleType.employee:
        return 1;
      case RoleType.subAdmin:
        return 2;
      case RoleType.manager:
        return 3;
    }
  }
}

extension GenderTypeExtension on GenderType {
  String get name {
    switch (this) {
      case GenderType.male:
        return 'Male';
      case GenderType.female:
        return 'Female';
      case GenderType.transgender:
        return 'TransGender';
    }
  }

  int get id {
    switch (this) {
      case GenderType.male:
        return 1;

      case GenderType.female:
        return 2;
      case GenderType.transgender:
        return 3;
    }
  }
}

/// Calculate polygon area in square feet from LatLng points
/// import 'dart:math';

double calculatePolygonAreaAcre({required List<LatLng?> points}) {
  if (points.length < 3) return 0.0;

  const earthRadiusMeters = 6371000.0; // Earth's radius in meters
  double area = 0.0;

  for (int i = 0; i < points.length; i++) {
    LatLng p1 = points[i]!;
    LatLng p2 = points[(i + 1) % points.length]!;

    double lat1 = p1.latitude * pi / 180;
    double lon1 = p1.longitude * pi / 180;
    double lat2 = p2.latitude * pi / 180;
    double lon2 = p2.longitude * pi / 180;

    area += (lon2 - lon1) * (2 + sin(lat1) + sin(lat2));
  }

  area = area * earthRadiusMeters * earthRadiusMeters / 2.0;

  double areaMeters = area.abs();

  // ✅ Convert m² → acres
  // 1 acre = 4046.8564224 m²
  double areaAcres = areaMeters / 4046.8564224;

  return double.parse(areaAcres.toStringAsFixed(2));
}


// void showLandArea() {
//   double areaSqFt = calculatePolygonAreaSqFt(landpolyline);
//   print("Land Area: ${areaSqFt.toStringAsFixed(2)} sq.ft");
// }


Future<Map<String, String?>> getAddressFromLatLng({required double latitude, required double longitude}) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;

      final address =
          '${place.name ?? ''}, ${place.street ?? ''}, ${place.locality ?? ''}, ${place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      final pincode = place.postalCode;

      return {
        'address': address,
        'pincode': pincode,
      };
    } else {
      return {
        'address': null,
        'pincode': null,
      };
    }
  } catch (e) {
    print('Error getting address: $e');
    return {
      'address': null,
      'pincode': null,
    };
  }
}
