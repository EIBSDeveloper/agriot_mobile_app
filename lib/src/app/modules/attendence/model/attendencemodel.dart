/*class EmployeeModel {
  final int id;
  final String name;
  final String role;
  final String salaryType;
  String? login;
  String? logout;
  String? hours;
  int? salary;
  bool? paidStatus;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.salaryType,
    this.login,
    this.logout,
    this.hours,
    this.salary,
    this.paidStatus,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "role": role,
    "salaryType": salaryType,
    "login": login,
    "logout": logout,
    "hours": hours,
    "salary": salary,
    "status": paidStatus,
  };

  /// CopyWith method to create a new object with updated fields
  EmployeeModel copyWith({
    int? id,
    String? name,
    String? role,
    String? salaryType,
    String? login,
    String? logout,
    String? hours,
    int? salary,
    bool? paidStatus,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      salaryType: salaryType ?? this.salaryType,
      login: login ?? this.login,
      logout: logout ?? this.logout,
      hours: hours ?? this.hours,
      salary: salary ?? this.salary,
      paidStatus: paidStatus ?? this.paidStatus,
    );
  }
}*/
class EmployeeModel {
  final int id;
  final String name;
  final String role;
  final String salaryType;
  final String? workType;
  final String? image;
  final String? login;
  final String? logout;
  final String? hours;
  final int? salary;
  final bool? paidStatus;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.salaryType,
    this.workType,
    this.image,
    this.login,
    this.logout,
    this.hours,
    this.salary,
    this.paidStatus,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      salaryType: json['salaryType'] ?? '',
      workType: json['work_type'],
      image: json['image'],
      login: json['login'],
      logout: json['logout'],
      hours: json['hours'],
      salary: (json['salary'] != null)
          ? int.tryParse(json['salary'].toString())
          : null,
      paidStatus: json['paid_status'] == 1 || json['paid_status'] == true,
    );

  Map<String, dynamic> toJson() => {
      "id": id,
      "name": name,
      "role": role,
      "salaryType": salaryType,
      "work_type": workType,
      "image": image,
      "login": login,
      "logout": logout,
      "hours": hours,
      "salary": salary,
      "paid_status": paidStatus,
    };

  EmployeeModel copyWith({
    int? id,
    String? name,
    String? role,
    String? salaryType,
    String? workType,
    String? image,
    String? login,
    String? logout,
    String? hours,
    int? salary,
    bool? paidStatus,
  }) => EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      salaryType: salaryType ?? this.salaryType,
      workType: workType ?? this.workType,
      image: image ?? this.image,
      login: login ?? this.login,
      logout: logout ?? this.logout,
      hours: hours ?? this.hours,
      salary: salary ?? this.salary,
      paidStatus: paidStatus ?? this.paidStatus,
    );
}
