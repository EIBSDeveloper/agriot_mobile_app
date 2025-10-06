import 'package:argiot/src/app/modules/employee/model/user_model.dart';

import '../../forming/model/soil_type.dart';
class EmployeeDetailsModel {
  final int id;
  final String name;
  final String email;
  final String mobileNo;
  final String AlternativeMobile;
  final SoilType role;
  final SoilType employeeType;
  final SoilType gender;
  final String? dob;
  final String doj;
  final String address;
  final String locations;
  final double latitude;
  final double longitude;
  final String pincode;
  final String description;
  // final Permissions permissions;
  final List<Employee> employees;

  EmployeeDetailsModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.AlternativeMobile,
    required this.role,
    required this.employeeType,
    required this.gender,
    this.dob,
    required this.doj,
    required this.address,
    required this.locations,
    required this.latitude,
    required this.longitude,
    required this.pincode,
    required this.description,
    // required this.permissions,
    required this.employees,
  });

  factory EmployeeDetailsModel.fromJson(Map<String, dynamic> json) => EmployeeDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      AlternativeMobile: json['alternative_mobile']?.toString() ?? '',
      role: SoilType.fromJson(json['role'] ?? {}),
      employeeType: SoilType.fromJson(json['employee_type'] ?? {}),
      gender: SoilType.fromJson(json['gender'] ?? {}),
      dob: json['dob'],
      doj: json['doj'] ?? '',
      address: json['address'] ?? '',
      locations: json['locations'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      pincode: (json['pincode'] ?? '').toString(),
      description: json['description'] ?? 
      '',
      // permissions: Permissions.fromJson(json['permissions'] ?? {}),
      employees: (json['employees'] as List<dynamic>?)
              ?.map((e) => Employee.fromJson(e))
              .toList() ??
          [],
    );

 }
