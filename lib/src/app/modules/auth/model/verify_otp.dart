class VerifyOtp {
  String? message;
  String? status;
  int? farmerID;

  VerifyOtp({this.message, this.status, this.farmerID});

  factory VerifyOtp.fromJson(Map<String, dynamic> json) {
    var farmer = json["farmer_details"];
    return VerifyOtp(
      message: json["message"] ?? json["detail"],
      status: json["status"],
      farmerID: farmer == null ? null : farmer["id"],
    );
  }
}
