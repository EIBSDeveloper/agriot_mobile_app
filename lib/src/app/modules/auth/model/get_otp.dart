import 'package:argiot/src/app/modules/auth/model/default_language.dart';

class GetOtp {
  String ?message;
  bool? user;
  int? userId;
  bool? details;
  bool? land;
  bool? crop;
   DefaultLanguage language;
  int? otp;

  GetOtp({
     this.message,
     this.user,
     this.userId,
    required this.details,
    required this.land,
    required this.crop,
    required this.language,
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
    language: DefaultLanguage.fromJson(farmer["language"]),
    otp: int.tryParse(farmer["otp"].toString())??0,
  );}


}
