
class EmployeePayoutsData {
  final int advanceAmount;

  EmployeePayoutsData({required this.advanceAmount});

  factory EmployeePayoutsData.fromJson(Map<String, dynamic> json) =>
      EmployeePayoutsData(
        advanceAmount: json['advance'] ,
      );
}

class UpdatePayoutsRequest {
  final int? id;
  final int? employeeId;
  final int? employeeWorkType;
  final String dateOfPayouts;
  final String advanceAmount;
  final String paidSalary;
  final String balanceAdvance;
  final String payoutAmount;
  final String unpaidSalary;
  final String previousAdvanceAmount;
  final double deductionAdvanceAmount;
  final double payoutsAmount;
  final double? toPay;
  final String? description;

  UpdatePayoutsRequest({
    this.id,
    required this.employeeId,
    required this.employeeWorkType,
    required this.dateOfPayouts,
    required this.deductionAdvanceAmount,
    required this.payoutsAmount,
    required this.balanceAdvance,
    required this.unpaidSalary,
    required this.payoutAmount,
    required this.previousAdvanceAmount,
    required this.paidSalary,
    required this.advanceAmount,
    this.toPay,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'employee_id': employeeId,
    'employee_type_id': employeeId,
    'date_of_payouts': dateOfPayouts,
    'advance_amount': advanceAmount,
    'paid_salary': paidSalary,
    'deduction_advance': deductionAdvanceAmount,
    'balance_advance': balanceAdvance,
    'payout_amount': payoutAmount,
    'unpaid_salary': unpaidSalary,
    'previous_advance_amount': previousAdvanceAmount,
    'payouts_amount': payoutsAmount,
    'to_pay': toPay,
    'description': description,
  };
}

class EmployeeAdvanceResponse {
  final bool status;
  final String message;
  final EmployeeAdvanceData? data;

  EmployeeAdvanceResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory EmployeeAdvanceResponse.fromJson(Map<String, dynamic> json) =>
      EmployeeAdvanceResponse(
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null
            ? EmployeeAdvanceData.fromJson(json['data'])
            : null,
      );
}

class EmployeeAdvanceData {
  final String employeeId;
  final String employeeName;
  final String employeeType;
  final double previousAdvance;
  final double totalAdvance;

  EmployeeAdvanceData({
    required this.employeeId,
    required this.employeeName,
    required this.employeeType,
    required this.previousAdvance,
    required this.totalAdvance,
  });

  factory EmployeeAdvanceData.fromJson(Map<String, dynamic> json) =>
      EmployeeAdvanceData(
        employeeId: json['employee_id'] ?? '',
        employeeName: json['employee_name'] ?? '',
        employeeType: json['employee_type'] ?? '',
        previousAdvance: (json['previous_advance'] ?? 0.0).toDouble(),
        totalAdvance: (json['total_advance'] ?? 0.0).toDouble(),
      );
}

class UpdateAdvanceRequest {
  final String employeeId;
  final String employeeType;
  final double advanceAmount;
  final double totalAdvance;
  final String? description;

  UpdateAdvanceRequest({
    required this.employeeId,
    required this.employeeType,
    required this.advanceAmount,
    required this.totalAdvance,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'employee_id': employeeId,
    'employee_type': employeeType,
    'advance_amount': advanceAmount,
    'total_advance': totalAdvance,
    'description': description,
  };
}

class Employee {
  final String id;
  final String name;
  final String phone;

  Employee({required this.id, required this.name, required this.phone});

  String get displayName => '$name - $phone';

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
  );
}
