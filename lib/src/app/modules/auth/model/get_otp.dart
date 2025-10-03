class GetOtp {
  String? message;
  bool? user;
  int? userId;
  bool? details;
  bool? land;
  bool? crop;
  int? otp;
  bool isManager;
  int? managerID;

  GetOtp({
    this.message,
    this.user,
    this.userId,
    required this.details,
    required this.land,
    required this.crop,
    required this.otp,
    this.isManager = false,
    this.managerID,
  });

  factory GetOtp.fromJson(Map<String, dynamic> json) {
    var farmer = json["farmer"];
    return GetOtp(
      message: json["message"],
      user: json["user"],
      userId: farmer["id"],
      details: json["details"],
      land: json["land"],
      crop: json["crop"],
      isManager: json["is_manager"] ?? false,
      managerID: json["manager_id"],
      otp: int.tryParse(farmer["otp"].toString()) ?? 0,
    );
  }
}
