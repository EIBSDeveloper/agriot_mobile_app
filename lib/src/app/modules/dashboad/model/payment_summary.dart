import 'package:argiot/src/app/modules/dashboad/model/both_payments.dart';
import 'package:argiot/src/app/modules/dashboad/model/customer_payments.dart';
import 'package:argiot/src/app/modules/dashboad/model/total_payments.dart';
import 'package:argiot/src/app/modules/dashboad/model/vendor_payments.dart';

class PaymentSummary {
  final VendorPayments vendor;
  final CustomerPayments customer;
  final BothPayments both;
  final TotalPayments total;

  PaymentSummary({
    required this.vendor,
    required this.customer,
    required this.both,
    required this.total,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) => PaymentSummary(
    vendor: VendorPayments.fromJson(json['vendor']),
    customer: CustomerPayments.fromJson(json['customer']),
    both: BothPayments.fromJson(json['both']),
    total: TotalPayments.fromJson(json['total']),
  );
}
