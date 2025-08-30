import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:as_hokme/game/presentation/pages/game_screen.dart';

/// ابزارهای کمکی برای نمایش پیام‌ها و دیالوگ‌ها
class UIHelper {
  static String version = '1.0.3';

  /// نمایش پیام کوتاه (SnackBar)
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 700),
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

  /// نمایش دیالوگ پایان ست با پیام‌های مختلف بر اساس نوع برد
  static Future<void> showEndSetDialog(
    BuildContext context,
    String winningTeam,
    bool isKod,
    bool isHakemKod,
    int pointsEarned,
    VoidCallback onContinue,
  ) async {
    final gameScreenCntrl = Get.put(GameScreen());
    gameScreenCntrl.showWinnerCelebration();
    int secondsLeft = 3;
    Timer? timer;

    // تعیین پیام و رنگ بر اساس نوع برد
    String message;
    Color textColor;
    String title;
    // IconData icon;

    if (winningTeam == 'team1') {
      // برد ما
      textColor = Colors.green;
      if (isHakemKod) {
        title = '🎉 حاکم کد! 🎉';
        message =
            'شما با حاکم کد بردید!\n\n🔥 خیلی عالی بودی! 🔥\n\n+3 امتیاز ست';
        // icon = Icons.celebration;
      } else if (isKod) {
        title = '🏆 کد! 🏆';
        message = 'شما با کد بردید!\n\n+2 امتیاز ست';
        // icon = Icons.emoji_events;
      } else {
        title = '✅ برنده ✅';
        message = 'شما این ست را بردید!\n\n+1 امتیاز ست';
        // icon = Icons.check_circle;
      }
    } else {
      // برد حریف
      textColor = Colors.red;
      if (isHakemKod) {
        title = '😱 حاکم کد حریف! 😱';
        message = 'حریف با حاکم کد برد!\n\n😔 3 امتیاز ست برای حریف';
        // icon = Icons.sentiment_very_dissatisfied;
      } else if (isKod) {
        title = '😤 کد حریف! 😤';
        message = 'حریف با کد برد!\n\n😔 2 امتیاز ست برای حریف';
        // icon = Icons.sentiment_dissatisfied;
      } else {
        title = '❌ باخت ❌';
        message = 'حریف این ست را برد!\n\n😔 1 امتیاز ست برای حریف';
        // icon = Icons.cancel;
      }
    }

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.grey[50],
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(icon, color: textColor, size: 28),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      timer?.cancel();
                      Get.back();
                      onContinue();
                      gameScreenCntrl.showWinnerCelebration();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: textColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        'ادامه در $secondsLeft ثانیه',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // actions: [
            //   Center(
            //     child: TextButton(
            //       onPressed: () {
            //         timer?.cancel();
            //         Get.back();
            //         onContinue();
            //       },
            //       style: TextButton.styleFrom(
            //         backgroundColor: textColor.withOpacity(0.1),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       ),
            //       child: Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            //         child: Text(
            //           'ادامه',
            //           style: TextStyle(
            //             color: textColor,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 16,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  /// نمایش دیالوگ پایان بازی با طراحی زیبا
  static Future<void> showEndGameDialog(
      BuildContext context, String message, Color? txtClr) async {
    // final gameScreenCntrl = Get.put(GameScreen());

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.grey[50],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              txtClr == Colors.green
                  ? Icons.celebration
                  : Icons.sentiment_very_dissatisfied,
              color: txtClr,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'پایان بازی',
              style: TextStyle(
                color: txtClr,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: txtClr,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //   decoration: BoxDecoration(
              //     color: txtClr?.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(
              //         color: txtClr?.withOpacity(0.3) ?? Colors.grey),
              // ),
              // child: Text(
              //   txtClr == Colors.green
              //       ? '🎉 تبریک! 🎉'
              //       : '😔 بهتر از این می‌توانید! 😔',
              //   style: TextStyle(
              //     color: txtClr,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // ),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              style: TextButton.styleFrom(
                backgroundColor: txtClr?.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'بستن',
                  style: TextStyle(
                    color: txtClr,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
