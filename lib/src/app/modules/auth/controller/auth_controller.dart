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
    // final account = await GoogleSignIn.instance.authenticate();
    final signIn = GoogleSignIn.instance;

    try {
      await signIn.initialize(
        clientId:
            "458442885060-g0hr2jk54rvosgoh0hhj70u46mra971g.apps.googleusercontent.com",
        serverClientId:
            "617838270571-5f0urgkbrv1egsnkrd7hq50nf2bde2go.apps.googleusercontent.com",
      );

      // Optional: try silent sign-in first
      await signIn.attemptLightweightAuthentication();

      if (signIn.supportsAuthenticate()) {
        final account = await signIn.authenticate();

        final tokens = account.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: tokens.idToken,
          // accessToken: tokens.accessToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        debugPrint(
          'User signed in: ${FirebaseAuth.instance.currentUser?.displayName}',
        );
      } else {
        debugPrint('authenticate() is not supported on this platform.');
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('❌ Google Sign-In canceled by user.');
        // Optionally show a Snackbar or dialog
      } else {
        // debugPrint('⚠️ Google Sign-In failed: ${e.code} - ${e.message}');
      }
    } catch (e) {
      debugPrint('🔥 Unexpected error: $e');
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
        AppDataController appData = Get.put(AppDataController());

        appData.userId.value = (response.farmerID ?? "").toString();

        await _storageService.saveUserData(response.farmerID!.toString());
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
