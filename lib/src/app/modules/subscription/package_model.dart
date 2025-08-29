import 'package:intl/intl.dart';

class PackageListResponse {
  final bool success;
  final List<Package> packages;

  PackageListResponse({required this.success, required this.packages});

  factory PackageListResponse.fromJson(Map<String, dynamic> json) {
    return PackageListResponse(
      success: json['success'] ?? false,
      packages: (json['packages'] as List)
          .map((package) => Package.fromJson(package['data']))
          .toList(),
    );
  }
}

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

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
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
  }

  String get formattedPrice {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  String get durationText {
    return '$packageValidity $packageDuration';
  }
}

class FarmerUsageResponse {
  final String name;
  final PackageUsage packageDetails;

  FarmerUsageResponse({required this.name, required this.packageDetails});

  factory FarmerUsageResponse.fromJson(Map<String, dynamic> json) {
    return FarmerUsageResponse(
      name: json['farmer']['name'] ?? '',
      packageDetails: (json['farmer']['package_details'] as List)
          .map((detail) => PackageUsage.fromJson(detail))
          .toList().first,
    );
  }
}

class PackageUsage {
  final int id;
  final String name;
  final int mylandCount;
  final int landCountUsed;
  final int mycropsCount;
  final int cropCountUsed;
  final int myexpenseCount;
  final int expenseCountUsed;
  final int mysaleCount;
  final int salesCountUsed;
  final int customerCount;
  final int customerCountUsed;
  final int myfuelCount;
  final int myfuelCountUsed;
  final int myvechicleCount;
  final int myvehicleCountUsed;
  final int mymachineryCount;
  final int mymachineryCountUsed;
  final int mytoolsCount;
  final int mytoolsCountUsed;
  final int mypesticidesCount;
  final int mypesticidesCountUsed;
  final int myfertilizersCount;
  final int myfertilizersCountUsed;
  final int myseedsCount;
  final int myseedsCountUsed;
  final int myinventoryVendors;
  final int myvendorCountUsed;
  final int employeeCount;
  final int employeeCountUsed;
  final bool isWidget;

  PackageUsage({
    required this.id,
    required this.name,
    required this.mylandCount,
    required this.landCountUsed,
    required this.mycropsCount,
    required this.cropCountUsed,
    required this.myexpenseCount,
    required this.expenseCountUsed,
    required this.mysaleCount,
    required this.salesCountUsed,
    required this.customerCount,
    required this.customerCountUsed,
    required this.myfuelCount,
    required this.myfuelCountUsed,
    required this.myvechicleCount,
    required this.myvehicleCountUsed,
    required this.mymachineryCount,
    required this.mymachineryCountUsed,
    required this.mytoolsCount,
    required this.mytoolsCountUsed,
    required this.mypesticidesCount,
    required this.mypesticidesCountUsed,
    required this.myfertilizersCount,
    required this.myfertilizersCountUsed,
    required this.myseedsCount,
    required this.myseedsCountUsed,
    required this.myinventoryVendors,
    required this.myvendorCountUsed,
    required this.employeeCount,
    required this.employeeCountUsed,
    required this.isWidget,
  });

  factory PackageUsage.fromJson(Map<String, dynamic> json) {
    return PackageUsage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mylandCount: json['myland_count'] ?? 0,
      landCountUsed: json['land_count_used'] ?? 0,
      mycropsCount: json['mycrops_count'] ?? 0,
      cropCountUsed: json['crop_count_used'] ?? 0,
      myexpenseCount: json['myexpense_count'] ?? 0,
      expenseCountUsed: json['expense_count_used'] ?? 0,
      mysaleCount: json['mysale_count'] ?? 0,
      salesCountUsed: json['sales_count_used'] ?? 0,
      customerCount: json['customer_count'] ?? 0,
      customerCountUsed: json['customer_count_used'] ?? 0,
      myfuelCount: json['myfuel_count'] ?? 0,
      myfuelCountUsed: json['myfuel_count_used'] ?? 0,
      myvechicleCount: json['myvechicle_count'] ?? 0,
      myvehicleCountUsed: json['myvehicle_count_used'] ?? 0,
      mymachineryCount: json['mymachinery_count'] ?? 0,
      mymachineryCountUsed: json['mymachinery_count_used'] ?? 0,
      mytoolsCount: json['mytools_count'] ?? 0,
      mytoolsCountUsed: json['mytools_count_used'] ?? 0,
      mypesticidesCount: json['mypesticides_count'] ?? 0,
      mypesticidesCountUsed: json['mypesticides_count_used'] ?? 0,
      myfertilizersCount: json['myfertilizers_count'] ?? 0,
      myfertilizersCountUsed: json['myfertilizers_count_used'] ?? 0,
      myseedsCount: json['myseeds_count'] ?? 0,
      myseedsCountUsed: json['myseeds_count_used'] ?? 0,
      myinventoryVendors: json['myinventory_vendors'] ?? 0,
      myvendorCountUsed: json['myvendor_count_used'] ?? 0,
      employeeCount: json['employee_count'] ?? 0,
      employeeCountUsed: json['employee_count_used'] ?? 0,
      isWidget: json['is_widget'] ?? false,
    );
  }

  // Balance Getters
  int get landBalance => _safeBalance(mylandCount, landCountUsed);
  int get cropBalance => _safeBalance(mycropsCount, cropCountUsed);
  int get expenseBalance => _safeBalance(myexpenseCount, expenseCountUsed);
  int get saleBalance => _safeBalance(mysaleCount, salesCountUsed);
  int get customerBalance => _safeBalance(customerCount, customerCountUsed);
  int get fuelBalance => _safeBalance(myfuelCount, myfuelCountUsed);
  int get vehicleBalance => _safeBalance(myvechicleCount, myvehicleCountUsed);
  int get machineryBalance =>
      _safeBalance(mymachineryCount, mymachineryCountUsed);
  int get toolsBalance => _safeBalance(mytoolsCount, mytoolsCountUsed);
  int get pesticidesBalance =>
      _safeBalance(mypesticidesCount, mypesticidesCountUsed);
  int get fertilizersBalance =>
      _safeBalance(myfertilizersCount, myfertilizersCountUsed);
  int get seedsBalance => _safeBalance(myseedsCount, myseedsCountUsed);
  int get vendorBalance => _safeBalance(myinventoryVendors, myvendorCountUsed);
  int get employeeBalance => _safeBalance(employeeCount, employeeCountUsed);

  // Helper method to ensure non-negative balance
  int _safeBalance(int total, int used) => (total - used).clamp(0, total);
}

class CreateOrderResponse {
  final String orderId;
  final String keyId;

  CreateOrderResponse({required this.orderId, required this.keyId});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['order_id'] ?? '',
      keyId: json['key_id'] ?? '',
    );
  }
}

class VerifyPaymentResponse {
  final String status;
  final String message;

  VerifyPaymentResponse({required this.status, required this.message});

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
