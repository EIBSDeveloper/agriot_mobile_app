import 'package:argiot/src/app/modules/employee/model/user_model.dart';

import '../../forming/model/soil_type.dart';

class EmployeeDetailsModel {
  final int id;
  final String name;
  final String profile;
  final String email;
  final String mobileNo;
  final int? salary;
  final int? advance;
  final String alternativeMobile;
  final SoilType role;
  final SoilType employeeType;
  final SoilType? workType;
  final SoilType? manager;
  final SoilType? gender;
  final String? dob;
  final String doj;
  final String address;
  final double latitude;
  final double longitude;
  final String pincode;
  final String? userName;
  final String? password;
  final bool? status;
  final String description;
  final List<Employee> employees;
  final Map<String, dynamic>? permissions;

  EmployeeDetailsModel({
    required this.id,
    required this.name,
    required this.profile,
    required this.email,
    required this.mobileNo,
    required this.alternativeMobile,
    this.salary,
    this.advance,
    required this.role,
    this.workType,
    this.manager,
    required this.employeeType,
    this.gender,
    this.dob,
    required this.doj,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pincode,
    required this.description,
    this.status,
    this.userName,
    this.password,
    required this.employees,
     this.permissions,
  });

  factory EmployeeDetailsModel.fromJson(Map<String, dynamic> json) =>
      EmployeeDetailsModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        profile: json['profile'] ?? '',
        email: json['email'] ?? '',
        mobileNo: json['mobile_no']?.toString() ?? '',
        alternativeMobile: json['alternative_mobile']?.toString() ?? '',
        salary: json['salary'],
        advance: json['advance'],
        role: SoilType.fromJson(json['role'] ?? {}),
        employeeType: SoilType.fromJson(json['employee_type'] ?? {}),
        workType: SoilType.fromJson(json['work_type'] ?? {}),
        manager: SoilType.fromJson(json['manager'] ?? {}),
        gender: SoilType.fromJson(json['gender'] ?? {}),
        dob: json['dob'],
        doj: json['doj'] ?? '',
        address: json['address'] ?? '',
        status: json['status'] != null
            ? json['status'] == 0
                  ? true
                  : false
            : null,
        latitude: (json['latitude'] ?? 0).toDouble(),
        longitude: (json['longitude'] ?? 0).toDouble(),
        pincode: (json['pincode'] ?? '').toString(),
        description: json['description'] ?? '',
        userName: json['user_name'],
        password: json['password'],
        permissions:  json['permissions'],
        employees:
            (json['employees'] as List<dynamic>?)
                ?.map((e) => Employee.fromJson(e))
                .toList() ??
            [],
      );

  EmployeeDetailsModel copyWith({
    int? id,
    String? name,
    String? profile,
    String? email,
    String? mobileNo,
    int? salary,
    int? advance,
    String? alternativeMobile,
    SoilType? role,
    SoilType? employeeType,
    SoilType? workType,
    SoilType? manager,
    SoilType? gender,
    String? dob,
    String? doj,
    String? address,
    double? latitude,
    double? longitude,
    String? pincode,
    String? userName,
    String? password,
    bool? status,
    String? description,
    List<Employee>? employees,
  }) => EmployeeDetailsModel(
    id: id ?? this.id,
    name: name ?? this.name,
    profile: profile ?? this.profile,
    email: email ?? this.email,
    mobileNo: mobileNo ?? this.mobileNo,
    salary: salary ?? this.salary,
    advance: advance ?? this.advance,
    alternativeMobile: alternativeMobile ?? this.alternativeMobile,
    role: role ?? this.role,
    employeeType: employeeType ?? this.employeeType,
    workType: workType ?? this.workType,
    manager: manager ?? this.manager,
    gender: gender ?? this.gender,
    dob: dob ?? this.dob,
    doj: doj ?? this.doj,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    pincode: pincode ?? this.pincode,
    userName: userName ?? this.userName,
    password: password ?? this.password,
    status: status ?? this.status,
    description: description ?? this.description,
    employees: employees ?? this.employees,
  );
}
