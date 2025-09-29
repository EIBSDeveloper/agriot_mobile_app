class EmployeeModel {
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
}
