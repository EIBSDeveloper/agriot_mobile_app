class EmployeePayoutsResponse {
  final bool status;
  final String message;
  final EmployeePayoutsData? data;

  EmployeePayoutsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory EmployeePayoutsResponse.fromJson(Map<String, dynamic> json) => EmployeePayoutsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? EmployeePayoutsData.fromJson(json['data']) : null,
    );
}

class EmployeePayoutsData {
  final String employeeName;
  final String employeeId;
  final double advanceAmount;
  final double balanceAdvance;
  final String employeeType;
  final String workType;

  EmployeePayoutsData({
    required this.employeeName,
    required this.employeeId,
    required this.advanceAmount,
    required this.balanceAdvance,
    required this.employeeType,
    required this.workType,
  });

  factory EmployeePayoutsData.fromJson(Map<String, dynamic> json) => EmployeePayoutsData(
      employeeName: json['employee_name'] ?? '',
      employeeId: json['employee_id'] ?? '',
      advanceAmount: (json['advance_amount'] ?? 0.0).toDouble(),
      balanceAdvance: (json['balance_advance'] ?? 0.0).toDouble(),
      employeeType: json['employee_type'] ?? '',
      workType: json['work_type'] ?? '',
    );
}

class UpdatePayoutsRequest {
  final String employeeId;
  final String dateOfPayouts;
  final double deductionAdvanceAmount;
  final double payoutsAmount;
  final double? toPay;
  final String? description;

  UpdatePayoutsRequest({
    required this.employeeId,
    required this.dateOfPayouts,
    required this.deductionAdvanceAmount,
    required this.payoutsAmount,
    this.toPay,
    this.description,
  });

  Map<String, dynamic> toJson() => {
      'employee_id': employeeId,
      'date_of_payouts': dateOfPayouts,
      'deduction_advance_amount': deductionAdvanceAmount,
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

  factory EmployeeAdvanceResponse.fromJson(Map<String, dynamic> json) => EmployeeAdvanceResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? EmployeeAdvanceData.fromJson(json['data']) : null,
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

  factory EmployeeAdvanceData.fromJson(Map<String, dynamic> json) => EmployeeAdvanceData(
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

  Employee({
    required this.id,
    required this.name,
    required this.phone,
  });

  String get displayName => '$name - $phone';

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
}