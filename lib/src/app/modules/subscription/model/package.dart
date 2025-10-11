import 'package:intl/intl.dart';

class Package {
  final int id;
  final String name;
  final String? code;
  final int packageValidity;
  final String? packageDuration;
  final double amount;
  final bool offer;
  final double? percentage;
  final double? subAmount;
  final int status;
  final int myLandCount;
  final int myCropsCount;
  final int employeeCount;
  final bool isUsingPackage;

  Package({
    required this.id,
    required this.name,
    this.code,
    required this.packageValidity,
    required this.packageDuration,
    required this.amount,
    required this.offer,
    this.percentage,
    this.subAmount,
    required this.status,
    required this.myLandCount,
    required this.myCropsCount,
    required this.employeeCount,
    required this.isUsingPackage,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'].toString(),
      packageValidity: json['package_validity'] ?? 0,
      packageDuration: json['package_duration'] ,
      amount: (json['amount'] ?? 0).toDouble(),
      offer: json['offer'] ?? false,
      percentage: json['percentage']?.toDouble(),
      subAmount: json['sub_amount']?.toDouble(),
      status: json['status'] ?? 0,
      myLandCount: json['myland_count'] ?? 0,
      myCropsCount: json['mycrops_count'] ?? 0,
      employeeCount: json['employee_count'] ?? 0,
      isUsingPackage: json['is_using_package'] ?? false,
    );

  String get formattedPrice {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  String get durationText => '$packageValidity - ${packageDuration??"days"}';
}
