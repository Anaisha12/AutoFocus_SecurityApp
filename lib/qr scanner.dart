import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:security_app_flutter/core/router.dart';
import 'package:security_app_flutter/generated/l10n.dart';
import 'package:security_app_flutter/utils/toast_utils.dart';
import 'package:security_app_flutter/viewmodels/base_viewmodel.dart';
import 'package:vibration/vibration.dart';

class ScanViewModel extends BaseViewModel {
  //Data:
  bool isFlashOn = false;
  GlobalKey qrKey = GlobalKey();
  late QRViewController controller;

  //Camera-related methods:
  void flipCamera() {
    controller.flipCamera();
  }

  void onPermission(QRViewController qr, bool hasPermission) {
    if (!hasPermission) {
      showToast(S.current.permissionError);
    }
  }

  void toggleFlash() {
    controller.toggleFlash();
    isFlashOn = !isFlashOn;
    notifyListeners();
  }

  //Misc. methods:
  bool isProperCode(String scannedCode) {
    final pattern = RegExp(r'^(STUDENT):\d{8}:[\d,a-z,-]+$');
    final pattern2 = RegExp(r'^(TEMPORARY_PERMIT):\d*:[\d,a-z,-]+$');
    return pattern.hasMatch(scannedCode) ||
        pattern2.hasMatch(scannedCode) ||
        (scannedCode.length == 8 && int.tryParse(scannedCode) != null);
  }

  //Initializer:
  void initQR(QRViewController qr) {
    controller = qr;
    controller.scannedDataStream.listen((scannedData) {
      if (scannedData.code == null) return;
      if (isProperCode(scannedData.code!)) {
        controller.pauseCamera();
        Vibration.vibrate(duration: 100);
        Get.toNamed(
          AppRoutes.confirmQR,
          arguments: scannedData.code,
        );
      }
    });
    refreshCamera();
    notifyListeners();
  }

  //Refresh
  void refreshCamera() {
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }
}