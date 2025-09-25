import 'dart:async';

import 'package:argiot/src/app/modules/profile/repository/profile_repository.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../controller/app_controller.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = Get.find();
  final AppDataController appData = Get.find();
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  // // Image handling
  // final RxString imagePath = ''.obs;
  // final RxString base64Image = ''.obs;

  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      signOutFromGoogle();
      await GetStorage().erase();
      appData.userId.value = '';
      appData.username.value = '';
      appData.emailId.value = '';
      Get.offAllNamed(Routes.login);
    } catch (e) {
      showError('Failed to logout');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Disconnect and sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect(); // Optional: removes account
        await googleSignIn.signOut();
      }

      debugPrint(' Successfully signed out from Google and Firebase');
    } catch (e) {
      debugPrint(' Sign-out failed: $e');
    }
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);

      final profileData = await _profileRepository.getProfile();
      profile(profileData);
    } catch (e) {
      showError('Failed to fetch profile');
    } finally {
      isLoading(false);
    }
  }

  // Future<void> pickImage() async {
  //   try {
  //     final pickedFile = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //     );
  //     if (pickedFile != null) {
  //       imagePath(pickedFile.path);
  //       final bytes = await pickedFile.readAsBytes();
  //       base64Image(base64Encode(bytes));
  //       await submitForm();
  //     }
  //   } catch (e) {
  //     showError('Failed to pick image');
  //   }
  // }

  // Future<void> submitForm() async {
  //   try {
  //     isSubmitting(true);

  //     final response = await _profileRepository.updateProfile({
  //       "name": profile.value?.name,
  //       "email": profile.value?.email,
  //       "door_no": profile.value?.doorNo,
  //       "pincode": profile.value?.pincode,
  //       "description": profile.value?.description,
  //       "company_name": profile.value?.companyName,
  //       "tax_no": profile.value?.taxNo,
  //       if (base64Image.isNotEmpty) "img": "data:image/png;base64,$base64Image",
  //     });

  //     if (response) {
  //       fetchProfile();
        
  //       showSuccess('Profile updated successfully');
  //     }
  //   } catch (e) {
  //     showError('Failed to update profile');
  //   } finally {
  //     isSubmitting(false);
  //   }
  // }
}
