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
    final orientation = MediaQuery.of(context).orientation;
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
                        fontFamily: 'Vazirmatn',
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF232526), // دارک خاکستری
                Color(0xFF414345), // دارک‌تر
              ],
            ),
          ),
          child: orientation == Orientation.portrait
              ? Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amberAccent.withOpacity(0.5),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/drawables/brand.png',
                                fit: BoxFit.cover,
                                width:
                                    (MediaQuery.of(context).size.width * 0.05) +
                                        200,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'بازی حکم ایرانی',
                              style: TextStyle(
                                fontSize:
                                    (MediaQuery.of(context).size.width * 0.01) +
                                        20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                                fontFamily: 'Vazirmatn',
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black54,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      cardListItems(context, 'شروع بازی',
                          () => Get.to(() => (GameScreen())),
                          icon: Icons.play_circle_outline_outlined,
                          color: Colors.greenAccent.shade400,
                          dark: true),
                      cardListItems(context, 'تنظیمات بازی',
                          () => Get.to(() => SettingsScreen()),
                          icon: Icons.settings_rounded,
                          color: Colors.blueAccent.shade100,
                          dark: true),
                      cardListItems(context, 'درباره ما',
                          () => Get.to(() => AbuteMeScreen()),
                          icon: Icons.info_outline_rounded,
                          color: Colors.orangeAccent.shade200,
                          dark: true),
                      cardListItems(context, 'ارسال لینک بازی', () {},
                          icon: Icons.share_rounded,
                          color: Colors.purpleAccent.shade100,
                          dark: true),
                      const SizedBox(height: 32),
                    ],
                  ),
                )
              : Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          cardListItems(context, 'شروع بازی',
                              () => Get.to(() => (GameScreen())),
                              icon: Icons.play_circle_outline_outlined,
                              color: Colors.greenAccent.shade400,
                              dark: true),
                          cardListItems(context, 'تنظیمات بازی',
                              () => Get.to(() => SettingsScreen()),
                              icon: Icons.settings_rounded,
                              color: Colors.blueAccent.shade100,
                              dark: true),
                          cardListItems(context, 'درباره ما',
                              () => Get.to(() => AbuteMeScreen()),
                              icon: Icons.info_outline_rounded,
                              color: Colors.orangeAccent.shade200,
                              dark: true),
                          cardListItems(context, 'ارسال لینک بازی', () {},
                              icon: Icons.share_rounded,
                              color: Colors.purpleAccent.shade100,
                              dark: true),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amberAccent.withOpacity(0.4),
                                  blurRadius: 70,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/drawables/brand.png',
                              fit: BoxFit.cover,
                              width: (MediaQuery.of(context).size.width * 0.2) +
                                  150,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'بازی حکم ایرانی',
                            style: TextStyle(
                              fontSize:
                                  (MediaQuery.of(context).size.width * 0.01) +
                                      22,
                              fontWeight: FontWeight.bold,
                              color: Colors.amberAccent,
                              fontFamily: 'Vazirmatn',
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget cardListItems(BuildContext context, String text, Function onTap,
      {IconData? icon, Color? color, bool dark = false}) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        width: (MediaQuery.of(context).size.width * 0.03) + 220,
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: dark
              ? const Color(0xFF232526).withOpacity(0.92)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (color ?? Colors.amberAccent).withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: color ?? Colors.amberAccent,
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: (color ?? Colors.amberAccent).withOpacity(0.2),
            highlightColor: (color ?? Colors.amberAccent).withOpacity(0.1),
            onTap: () {
              onTap();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 15, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      color: color ?? Colors.amberAccent),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: color ?? Colors.amberAccent,
                      fontFamily: 'Vazirmatn',
                    ),
                  ),
                  if (icon != null) ...[
                    Icon(icon, color: color ?? Colors.amberAccent, size: 26),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
