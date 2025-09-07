import 'package:argiot/src/app/modules/subscription/model/package_usage.dart';

class FarmerUsageResponse {
  final String name;
  final PackageUsage packageDetails;

  FarmerUsageResponse({required this.name, required this.packageDetails});

  factory FarmerUsageResponse.fromJson(Map<String, dynamic> json) => FarmerUsageResponse(
      name: json ['name'] ?? '',
      packageDetails: (json ['package_details'] as List)
          .map((detail) => PackageUsage.fromJson(detail))
          .toList().first,
    );
}
