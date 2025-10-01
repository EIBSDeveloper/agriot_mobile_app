class VerifyOtp {
  String? message;
  String? status;
  int? farmerID;
  bool isManager;
  int? managerID;

  VerifyOtp({
    this.message,
    this.status,
    this.farmerID,
    this.isManager = false,
    this.managerID,
  });

  factory VerifyOtp.fromJson(Map<String, dynamic> json) {
    var farmer = json["farmer_details"];
    return VerifyOtp(
      message: json["message"] ?? json["detail"],
      status: json["status"],
      isManager: json["is_manager"] ?? false,
      managerID: json["manager_id"],
      farmerID: farmer == null ? null : farmer["id"],
    );
  }
}
