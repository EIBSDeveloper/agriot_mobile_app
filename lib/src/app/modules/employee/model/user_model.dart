class UserModel {
  final int id;
  final String name;
  final String role;
  final String number;
  final String address;
  final String profile;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.number,
    required this.address,
    required this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      number: json['number']?.toString() ?? '',
      address: json['address'] ?? '',
      profile: json['profile'] ?? '',
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'role': role,
      'number': number,
      'address': address,
      'profile': profile,
    };
}
class ManagerEmployeeGroup {
  final Manager manager;
  final List<Employee> employees;

  ManagerEmployeeGroup({
    required this.manager,
    required this.employees,
  });

  factory ManagerEmployeeGroup.fromJson(Map<String, dynamic> json) => ManagerEmployeeGroup(
      manager: Manager.fromJson(json['manager']),
      employees: (json['employees'] as List)
          .map((e) => Employee.fromJson(e))
          .toList(),
    );
}

class Manager {
  final int id;
  final String name;
  final String mobileNo;
  final String email;

  Manager({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.email,
  });

  factory Manager.fromJson(Map<String, dynamic> json) => Manager(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mobileNo: (json['mobile_no'] ?? '').toString(),
      email: json['email'] ?? '',
    );

  // Convert to UserModel for compatibility
  UserModel toUserModel() => UserModel(
      id: id,
      name: name,
      role: 'Manager',
      number: mobileNo,
      address: email,
      profile: '',
    );
}

class Employee {
  final int id;
  final String name;
  final String mobileNo;
  final int? employeeTypeId;
  final int? workTypeId;
  final int status;

  Employee({
    required this.id,
    required this.name,
    required this.mobileNo,
    this.employeeTypeId,
    this.workTypeId,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mobileNo: (json['mobile_no'] ?? '').toString(),
      employeeTypeId: json['employee_type_id'],
      workTypeId: json['work_type_id'],
      status: json['status'] ?? 0,
    );

  // Convert to UserModel for compatibility
  UserModel toUserModel() => UserModel(
      id: id,
      name: name,
      role: 'Employee',
      number: mobileNo,
      address: '',
      profile: '',
    );
}