import 'package:intl/intl.dart';

class PayoutModel {
  final int id;
  final String name;
  final String role;
  final String salaryType;
  final String workType;
  final String? image;
  final int workingDays;
  final int paidSalary;
  final int unpaidSalary;
  int? advance;
  int? deductionAdvance;
  int? payoutAmount;
  bool isEdited; // updated to non-nullable

  PayoutModel({
    required this.id,
    required this.name,
    required this.role,
    required this.salaryType,
    required this.workType,
    this.image,
    required this.workingDays,
    required this.paidSalary,
    required this.unpaidSalary,
    this.advance,
    this.deductionAdvance,
    this.payoutAmount,
    this.isEdited = false, // default false
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) => PayoutModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    role: json['role'] ?? '',
    salaryType: json['salaryType'] ?? '',
    workType: json['work_type'] ?? '',
    image: json['image'],
    workingDays: json['working_days'] ?? 0,
    paidSalary: (json['paid_salary'] is double
        ? (json['paid_salary'] as double).toInt()
        : json['paid_salary'] ?? 0),
    unpaidSalary: (json['Unpaid_salary'] is double
        ? (json['Unpaid_salary'] as double).toInt()
        : json['Unpaid_salary'] ?? 0),
    advance: (json['advance'] is double
        ? (json['advance'] as double).toInt()
        : json['advance']),
    deductionAdvance: (json['deduction'] is double
        ? (json['deduction'] as double).toInt()
        : json['deduction']),
    payoutAmount: (json['payout_amount'] is double
        ? (json['payout_amount'] as double).toInt()
        : json['payout_amount']),
    isEdited: json['isEdited'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'employee_id': id,
    'paid_salary': paidSalary,
    'unpaid_salary': unpaidSalary,
    'advance': advance,
    'deduction_advance': deductionAdvance,
    'balance_advance': (advance ?? 0) - (deductionAdvance ?? 0),
    'payout_amount': payoutAmount,
    'to_pay': payoutAmount,
    "date":  DateFormat("yyyy-MM-dd").format(DateTime.now()),
  };

  static List<PayoutModel> listFromJson(List<dynamic> jsonList) =>
      jsonList.map((json) => PayoutModel.fromJson(json)).toList();
}
