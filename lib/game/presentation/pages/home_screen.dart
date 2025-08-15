import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:persian_hokm/game/presentation/pages/abute_me.dart';
import 'package:persian_hokm/game/presentation/pages/game_screen.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';
import 'package:persian_hokm/game/presentation/widgets/card_list_ittems.dart';
import 'package:persian_hokm/game/presentation/widgets/screen_size_guard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? lastBackPressTime;
    final orientation = MediaQuery.of(context).orientation;
    var listItem = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CardListItem(
            text: 'شروع بازی',
            onTap: () => Get.to(
                transition: Transition.leftToRight,
                duration: const Duration(milliseconds: 600),
                () => (GameScreen())),
            icon: Icons.play_circle_outline_outlined,
            color: Colors.greenAccent.shade400,
            dark: true),
        CardListItem(
          text: 'تنظیمات بازی',
          onTap: () => Get.to(
            transition: Transition.leftToRight,
            duration: const Duration(milliseconds: 600),
            () => SettingsScreen(),
          ),
          icon: Icons.settings_rounded,
          color: Colors.blueAccent.shade100,
          dark: true,
        ),
        CardListItem(
            text: 'درباره ما',
            onTap: () => Get.to(
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 600), () {
                  return AbuteMeScreen();
                }),
            icon: Icons.info_outline_rounded,
            color: Colors.orangeAccent.shade200,
            dark: true),
        CardListItem(
            text: 'نسخه 1.0.3',
            color: Colors.purpleAccent.shade100,
            dark: true),
      ],
    );
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
        body: ScreenSizeGuard(
          child: Container(
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
                                      color:
                                          Colors.amberAccent.withOpacity(0.5),
                                      blurRadius: 40,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/drawables/brand.png',
                                  fit: BoxFit.cover,
                                  width: (MediaQuery.of(context).size.width *
                                          0.05) +
                                      200,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'بازی آس حکم',
                                style: TextStyle(
                                  fontSize: (MediaQuery.of(context).size.width *
                                          0.01) +
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
                        listItem,
                        const SizedBox(height: 32),
                      ],
                    ),
                  )
                : Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        listItem,
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
                                width:
                                    (MediaQuery.of(context).size.width * 0.2) +
                                        150,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'بازی آس حکم',
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
      ),
    );
  }
}
