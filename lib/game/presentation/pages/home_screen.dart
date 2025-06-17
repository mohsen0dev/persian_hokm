import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/game/presentation/pages/abute_me.dart';
import 'package:persian_hokm/game/presentation/pages/game_screen.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? lastBackPressTime;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, PopupRoute? route) async {
        if (!didPop) {
          final now = DateTime.now();
          if (lastBackPressTime == null ||
              now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
            lastBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 16),
                    Text(
                      'برای خروج دوباره دکمه برگشت را فشار دهید',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.redo_rounded, color: Colors.white),
                    SizedBox(width: 16),
                  ],
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.black,
              ),
            );
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: Center(
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: Text(
                    'بازی حکم ایرانی',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Center(
                    child: cardListItems(context, 'شروع بازی',
                        () => Get.to(() => (GameScreen())))),
                cardListItems(
                  context,
                  'تنظیمات بازی',
                  () => Get.to(() => SettingsScreen()),
                ),
                cardListItems(
                  context,
                  'درباره ما',
                  () => Get.to(() => AbuteMeScreen()),
                ),
                cardListItems(context, 'ارسال لینک بازی', () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Center cardListItems(BuildContext context, String text, Function onTap) =>
      Center(
        child: Container(
          width: 180,
          height: 45,
          margin: EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration: BoxDecoration(
            // color: Colors.red,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.red,
              width: 0.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              onTap();
            },
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
}
