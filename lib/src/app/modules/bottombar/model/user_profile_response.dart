import 'package:argiot/src/app/modules/bottombar/model/user_profile_model.dart';

class UserProfileResponse {
  final bool success;
  final String message;
  final UserProfile userProfile;

  UserProfileResponse({
    required this.success,
    required this.message,
    required this.userProfile,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) => UserProfileResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      userProfile: UserProfile.fromJson(json),
    );
}