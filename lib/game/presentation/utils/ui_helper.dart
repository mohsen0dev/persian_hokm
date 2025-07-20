import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ابزارهای کمکی برای نمایش پیام‌ها و دیالوگ‌ها
class UIHelper {
  /// نمایش پیام کوتاه (SnackBar)
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 500),
        width: 150,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 10,
        content: Text(
          textAlign: TextAlign.center,
          message,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// نمایش دیالوگ پایان ست
  static Future<void> showEndSetDialog(
      BuildContext context, String message, VoidCallback onContinue) async {
    int secondsLeft = 3;
    Timer? timer;
    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          timer ??= Timer.periodic(Duration(seconds: 1), (t) {
            if (secondsLeft > 1) {
              setState(() => secondsLeft--);
            } else {
              t.cancel();
              Get.back();
              onContinue();
            }
          });
          return AlertDialog(
            title: Text('ست جدید'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Get.back();
                  onContinue();
                },
                child: Text('ادامه ( $secondsLeft)'),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  /// نمایش دیالوگ پایان بازی
  static Future<void> showEndGameDialog(
      BuildContext context, String message) async {
    await Get.dialog(
      AlertDialog(
        title: Text('پایان بازی'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text('بستن'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
