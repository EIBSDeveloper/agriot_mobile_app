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
