import 'package:argiot/src/app/modules/subscription/model/package.dart';

class PackageListResponse {
  final bool success;
  final List<Package> packages;

  PackageListResponse({required this.success, required this.packages});

  factory PackageListResponse.fromJson(Map<String, dynamic> json) => PackageListResponse(
      success: json['success'] ?? false,
      packages: (json['packages'] as List)
          .map((package) => Package.fromJson(package['data']))
          .toList(),
    );
}
