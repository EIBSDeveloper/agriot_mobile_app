class EmployeeDetailsModel {
  final int id;
  final String name;
  final String profile;
  final String joiningDate;
  final String? userName;
  final String? password;
  final String gender;
  final String role;
  final String salaryType;
  final double salary;
  final String mobileNumber;
  final String alternativeMobileNumber;
  final String emailId;
  final String pincode;
  final String description;

  EmployeeDetailsModel({
    required this.id,
    required this.name,
    required this.profile,
    required this.joiningDate,
    this.userName,
    this.password,
    required this.gender,
    required this.role,
    required this.salaryType,
    required this.salary,
    required this.mobileNumber,
    required this.alternativeMobileNumber,
    required this.emailId,
    required this.pincode,
    required this.description,
  });

  factory EmployeeDetailsModel.fromJson(Map<String, dynamic> json) => EmployeeDetailsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profile: json['profile'] ?? '',
      joiningDate: json['joing_date'] ?? '',
      userName: json['user_name'],
      password: json['password'],
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      salaryType: json['salary_type'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
      mobileNumber: json['mobile_number']?.toString() ?? '',
      alternativeMobileNumber: json['alternative_mobile_number']?.toString() ?? '',
      emailId: json['email_id'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
      description: json['discription'] ?? '',
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'profile': profile,
      'joing_date': joiningDate,
      'user_name': userName,
      'password': password,
      'gender': gender,
      'role': role,
      'salary_type': salaryType,
      'salary': salary,
      'mobile_number': mobileNumber,
      'alternative_mobile_number': alternativeMobileNumber,
      'email_id': emailId,
      'pincode': pincode,
      'discription': description,
    };
}