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
  final String description;
  // final Permissions permissions;
  final List<Employee> employees;

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
    this.userName,
    this.password,
    // required this.permissions,
    required this.employees,
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
        advance: json['advance'] ,
        role: SoilType.fromJson(json['role'] ?? {}),
        employeeType: SoilType.fromJson(json['employee_type'] ?? {}),
        workType: SoilType.fromJson(json['work_type'] ?? {}),
        manager: SoilType.fromJson(json['manager'] ?? {}),
        gender: SoilType.fromJson(json['gender'] ?? {}),
        dob: json['dob'],
        doj: json['doj'] ?? '',
        address: json['address'] ?? '',
        latitude: (json['latitude'] ?? 0).toDouble(),
        longitude: (json['longitude'] ?? 0).toDouble(),
        pincode: (json['pincode'] ?? '').toString(),
        description: json['description'] ?? '',
        userName: json['user_name'] ,
        password: json['password'] ,
        // permissions: Permissions.fromJson(json['permissions'] ?? {}),
        employees:
            (json['employees'] as List<dynamic>?)
                ?.map((e) => Employee.fromJson(e))
                .toList() ??
            [],
      );
}
