// gender_model.dart
class GenderModel {
  final int id;
  final String name;

  GenderModel({required this.id, required this.name});

  factory GenderModel.fromJson(Map<String, dynamic> json) {
    return GenderModel(id: json['id'], name: json['name']);
  }
}

// employee_type_model.dart
class EmployeeTypeModel {
  final int id;
  final String name;

  EmployeeTypeModel({required this.id, required this.name});

  factory EmployeeTypeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeTypeModel(id: json['id'], name: json['name']);
  }
}

// role_model.dart
class RoleModel {
  final int id;
  final String name;

  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(id: json['id'], name: json['name']);
  }
}
