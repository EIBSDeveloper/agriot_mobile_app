

class GetOtp {
  String ?message;
  bool? user;
  int? userId;
  bool? details;
  bool? land;
  bool? crop;
  int? otp;

  GetOtp({
     this.message,
     this.user,
     this.userId,
    required this.details,
    required this.land,
    required this.crop,
    required this.otp,
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
    otp: int.tryParse(farmer["otp"].toString())??0,
  );}


}
