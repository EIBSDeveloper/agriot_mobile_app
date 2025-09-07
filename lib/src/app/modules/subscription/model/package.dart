import 'package:intl/intl.dart';

class Package {
  final int id;
  final String name;
  final String? code;
  final int packageValidity;
  final String packageDuration;
  final double amount;
  final bool offer;
  final double? percentage;
  final double? subAmount;
  final int status;
  final int mylandCount;
  final int mycropsCount;
  final int myexpenseCount;
  final int mysaleCount;
  final int customerCount;
  final bool isMyvechicle;
  final int myvechicleCount;
  final bool isMymachinery;
  final int mymachineryCount;
  final bool isMytools;
  final int mytoolsCount;
  final bool isMyinventory;
  final int myinventoryProducts;
  final int myinventoryPurchase;
  final int myinventoryVendors;
  final bool isAttendance;
  final int employeeCount;
  final bool isPayouts;
  final bool isWidget;
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
    required this.mylandCount,
    required this.mycropsCount,
    required this.myexpenseCount,
    required this.mysaleCount,
    required this.customerCount,
    required this.isMyvechicle,
    required this.myvechicleCount,
    required this.isMymachinery,
    required this.mymachineryCount,
    required this.isMytools,
    required this.mytoolsCount,
    required this.isMyinventory,
    required this.myinventoryProducts,
    required this.myinventoryPurchase,
    required this.myinventoryVendors,
    required this.isAttendance,
    required this.employeeCount,
    required this.isPayouts,
    required this.isWidget,
    required this.isUsingPackage,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'],
      packageValidity: json['package_validity'] ?? 0,
      packageDuration: json['package_duration'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      offer: json['offer'] ?? false,
      percentage: json['percentage']?.toDouble(),
      subAmount: json['sub_amount']?.toDouble(),
      status: json['status'] ?? 0,
      mylandCount: json['myland_count'] ?? 0,
      mycropsCount: json['mycrops_count'] ?? 0,
      myexpenseCount: json['myexpense_count'] ?? 0,
      mysaleCount: json['mysale_count'] ?? 0,
      customerCount: json['customer_count'] ?? 0,
      isMyvechicle: json['is_myvechicle'] ?? false,
      myvechicleCount: json['myvechicle_count'] ?? 0,
      isMymachinery: json['is_mymachinery'] ?? false,
      mymachineryCount: json['mymachinery_count'] ?? 0,
      isMytools: json['is_mytools'] ?? false,
      mytoolsCount: json['mytools_count'] ?? 0,
      isMyinventory: json['is_myinventory'] ?? false,
      myinventoryProducts: json['myinventory_products'] ?? 0,
      myinventoryPurchase: json['myinventory_purchase'] ?? 0,
      myinventoryVendors: json['myinventory_vendors'] ?? 0,
      isAttendance: json['is_attendance'] ?? false,
      employeeCount: json['employee_count'] ?? 0,
      isPayouts: json['is_payouts'] ?? false,
      isWidget: json['is_widget'] ?? false,
      isUsingPackage: json['is_using_package'] ?? false,
    );

  String get formattedPrice {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  String get durationText => '$packageValidity $packageDuration';
}
