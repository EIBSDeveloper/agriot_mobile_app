// models/sales_model.dart

import 'package:argiot/src/app/modules/sales/model/reason.dart';
import 'package:argiot/src/app/modules/sales/model/rupee.dart';

class Deduction {
  final int deductionId;
  final Reason reason;
  final String charges;
  final Rupee rupee;

  Deduction({
    required this.deductionId,
    required this.reason,
    required this.charges,
    required this.rupee,
  });

  factory Deduction.fromJson(Map<String, dynamic> json) => Deduction(
    deductionId: json['deduction_id'] ?? 0,
    reason: Reason.fromJson(json['reason'] ?? {}),
    charges: json['charges'] ?? '',
    rupee: Rupee.fromJson(json['rupee'] ?? {}),
  );
}
