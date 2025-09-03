import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../routes/app_routes.dart';
import '../../../controller/app_controller.dart';
import '../../../controller/storage_service.dart';
import '../../../widgets/local_notifications.dart';
import '../model/auth_model.dart';
import '../repository/auth_repository.dart';
import '../model/otp.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final StorageService _storageService = Get.put(StorageService());

  final RxBool isLoading = false.obs;
  final RxString mobileNumber = ''.obs;
  final RxString otp = ''.obs;
  final RxInt currentStep = 0.obs;

  final RxString name = ''.obs;
  Rx<bool?> isEmail = Rx<bool?>(null);

  Future<void> sendOtp() async {
    if (isValidMobile(mobileNumber.value)) {
      isEmail.value = false;
    } else if (isValidEmail(mobileNumber.value)) {
      isEmail.value = true;
    } else if (!isValidMobile(mobileNumber.value) &&
        !isValidEmail(mobileNumber.value)) {
      Fluttertoast.showToast(
        msg: 'Invalid input',
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authRepository.loginWithMobile(
        mobileNumber.value,
        isEmail.value!,
      );

      showNotification(
        title: "APF",
        body: "Your Login OTP is:${response.otp} ",
        payload: {},
      );

      if (response.user != null) {
        AppDataController appData = Get.put(AppDataController());
        appData.loginState.value = response;
        Get.toNamed(Routes.otp);
        Fluttertoast.showToast(msg: "OTP sent to your mobile", fontSize: 16.0);
      } else {
        throw Exception(response.message ?? 'Failed to send OTP');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.redAccent,
        fontSize: 16.0,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? signIn = await GoogleSignIn().signIn();

      if (signIn == null) {
        debugPrint('⚠️ User cancelled Google Sign-In');
        return;
      }

      final GoogleSignInAuthentication account = await signIn.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: account.idToken,
        accessToken: account.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        debugPrint('✅ Signed in as ${user.email}');

        final response = await _authRepository.loginWithMobile(
          user.email!,
          true,
          isGoogleLogin: true,
        );

        if (response.userId != null) {
          AppDataController appData = Get.put(AppDataController());
          appData.loginState.value = response;
          await authWrapper(response.userId);
        } else {
          throw Exception(response.message ?? 'Invalid OTP');
        }
      }
    } catch (e) {
      debugPrint('🔥 Sign-in failed: $e');
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

      debugPrint('✅ Successfully signed out from Google and Firebase');
    } catch (e) {
      debugPrint('🔥 Sign-out failed: $e');
    }
  }

  Future<void> verifyOtp() async {
    try {
      isLoading.value = true;
      VerifyOtp response = await _authRepository.verifyOtp(
        mobileNumber.value,
        otp.value,
        isEmail.value!,
      );
      if (response.status != null && response.farmerID != null) {
        await authWrapper(response.farmerID);
      } else {
        throw Exception(response.message ?? 'Invalid OTP');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.redAccent,
        // gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> authWrapper(farmerID) async {
    AppDataController appData = Get.put(AppDataController());

    appData.userId.value = (farmerID ?? "").toString();

    await _storageService.saveUserData(farmerID!.toString());
    Future.delayed(const Duration(milliseconds: 500), () async {
      await _storageService.updateUser();
      GetOtp? loginState = appData.loginState.value;
      if (!(loginState!.details ?? true)) {
        Get.offAllNamed(Routes.register, arguments: 0);
      } else if (!(loginState.land ?? true)) {
        Get.offAllNamed(Routes.register, arguments: 1);
      } else if (!(loginState.crop ?? true)) {
        Get.offAllNamed(Routes.register, arguments: 2);
      } else {
        await _storageService.updateLoginState(true);
        Get.offAllNamed(Routes.home);
      }
    });
  }

  bool isValidMobile(String input) {
    // Check if input is exactly 10 digits
    final mobileRegex = RegExp(r'^\d{10}$');
    return mobileRegex.hasMatch(input);
  }

  bool isValidEmail(String input) {
    // Simple email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(input);
  }
}
