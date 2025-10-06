// gender_model.dart
class GenderModel {
  final int id;
  final String name;

  GenderModel({required this.id, required this.name});

  factory GenderModel.fromJson(Map<String, dynamic> json) =>
      GenderModel(id: json['id'], name: json['name']);
}

// employee_type_model.dart
class EmployeeTypeModel {
  final int id;
  final String name;

  EmployeeTypeModel({required this.id, required this.name});

  factory EmployeeTypeModel.fromJson(Map<String, dynamic> json) =>
      EmployeeTypeModel(id: json['id'], name: json['name']);
}

// role_model.dart
class RoleModel {
  final int id;
  final String name;

  RoleModel({required this.id, required this.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      RoleModel(id: json['id'], name: json['name']);
}

class WorkTypeModel {
  final int id;
  final String name;

  WorkTypeModel({required this.id, required this.name});

  factory WorkTypeModel.fromJson(Map<String, dynamic> json) => WorkTypeModel(id: json['id'], name: json['name']);
}

class AssignMangerModel {
  final int? id;
  final String name;

  AssignMangerModel({required this.id, required this.name});

  factory AssignMangerModel.fromJson(Map<String, dynamic> json) => AssignMangerModel(id: json['id'], name: json['name']);
}
