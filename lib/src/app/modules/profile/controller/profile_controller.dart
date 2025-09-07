
import 'dart:async';

import 'package:argiot/src/app/modules/profile/repository/profile_repository.dart';
import 'package:argiot/src/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../service/utils/utils.dart';
import '../model/profile_model.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = Get.find();
  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchProfile();
    super.onInit();
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // final response = await _repository.logout();

      // if (response.success) {
      // Clear storage and navigate to login
      signOutFromGoogle();
      await GetStorage().erase();

      Get.offAllNamed(Routes.login);
      // } else {
      //   Fluttertoast.showToast();
      // }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to logout',
        backgroundColor: Colors.redAccent,
        // gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
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
}
