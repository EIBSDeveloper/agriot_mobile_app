import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final isConnected = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _dialogShown = false;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _init() async {
    await _checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (_) => _checkConnection(),
    );
  }

  Future<void> _checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final newStatus = results.any(
        (result) => result != ConnectivityResult.none,
      );

      if (isConnected.value != newStatus) {
        isConnected.value = newStatus;

        if (!newStatus) {
          _showNoInternetDialog();
          _showConnectionLostToast();
        } else {
          _dismissDialog();
          _showConnectionRestoredToast();
        }
      }
    } catch (e) {
      _showConnectionErrorToast();
    }
  }

  void _showNoInternetDialog() {
    if (!_dialogShown) {
      _dialogShown = true;
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text("no_internet_title".tr),
            content: Text("no_internet_message".tr),
            actions: [
              TextButton(
                onPressed: () => _dismissDialog(),
                child: Text("ok_button".tr),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  void _dismissDialog() {
    if (_dialogShown) {
      _dialogShown = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }

  void _showConnectionLostToast() {
    // showError();
    Get.snackbar(
      "connection_lost_title".tr,
      "connection_lost_message".tr,
     
      backgroundColor: Colors.red.withAlpha(180),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      icon: const Icon(Icons.wifi_off, color: Colors.white),
    );
  }

  void _showConnectionRestoredToast() {
    Get.snackbar(
      "connection_restored_title".tr,
      "connection_restored_message".tr,
      backgroundColor: Colors.green.withAlpha(180),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      icon: const Icon(Icons.wifi, color: Colors.white),
    );
  }

  void _showConnectionErrorToast() {
    Get.snackbar(
      "connection_error_title".tr,
      "connection_error_message".tr,
      backgroundColor: Colors.orange.withAlpha(180),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
