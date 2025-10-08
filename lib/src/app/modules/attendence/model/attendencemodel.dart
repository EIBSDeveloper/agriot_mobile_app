import 'dart:convert';

import 'package:intl/intl.dart';

class EmployeeModel {
  final int id;
  final String name;
  final String role;
  final String salaryType;
  final String? workType;
  final String? image;
  final bool present;
  final String? loginTime;
  final String? logoutTime;
  final String? totalHour;
  final String? salary;
  final int? salaryPerHour; // int field
  final bool? salaryStatus;
  final bool isEdited; // updated to non-nullable

  EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.salaryType,
    this.workType,
    this.image,
    required this.present,
    this.loginTime,
    this.logoutTime,
    this.totalHour,
    this.salary,
    this.salaryPerHour,
    this.salaryStatus,
    this.isEdited = false, // default false
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    role: json['role'] ?? '',
    salaryType: json['salaryType'] ?? json['salary_type'] ?? '',
    workType: json['work_type'],
    image: json['image'],
    present: json['present'] ?? false,
    loginTime: json['login_time'],
    logoutTime: json['logout_time'],
    totalHour: (json['total_hour'] ?? '').toString(),
    salary: (json['salary'] ?? '').toString(),
    salaryPerHour: json['salary_per_hour'] ?? 0,
    salaryStatus: (json['salary_status'] is int)
        ? json['salary_status'] == 1
        : (json['salary_status'] as bool?),
    isEdited: json['isEdited'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_day": DateFormat("yyyy-MM-dd").format(DateTime.now()),
    "login_time": loginTime,
    "logout_time": logoutTime,
    "salary": salary != null && salary!.isNotEmpty ? salary : 0.0,
    "salary_per_hour": salaryPerHour ?? 0,
    "salary_status": salaryStatus,
    "isEdited": isEdited,
  };

  EmployeeModel copyWith({
    int? id,
    String? name,
    String? role,
    String? salaryType,
    String? workType,
    String? image,
    bool? present,
    String? loginTime,
    String? logoutTime,
    String? totalHour,
    String? salary,
    int? salaryPerHour,
    bool? salaryStatus,
    bool? isEdited,
  }) => EmployeeModel(
    id: id ?? this.id,
    name: name ?? this.name,
    role: role ?? this.role,
    salaryType: salaryType ?? this.salaryType,
    workType: workType ?? this.workType,
    image: image ?? this.image,
    present: present ?? this.present,
    loginTime: loginTime ?? this.loginTime,
    logoutTime: logoutTime ?? this.logoutTime,
    totalHour: totalHour ?? this.totalHour,
    salary: salary ?? this.salary,
    salaryPerHour: salaryPerHour ?? this.salaryPerHour,
    salaryStatus: salaryStatus ?? this.salaryStatus,
    isEdited: isEdited ?? this.isEdited,
  );

  static List<EmployeeModel> listFromJson(String str) =>
      List<EmployeeModel>.from(
        json.decode(str).map((x) => EmployeeModel.fromJson(x)),
      );
}
