import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AbuteMeScreen extends StatelessWidget {
  const AbuteMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درباره ما'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 2,
      ),
      body: Container(
        // padding: EdgeInsets.only(left: 30, right: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF232526),
              Color(0xFF414345),
            ],
          ),
        ),
        child: Center(
          child: Card(
            color: Colors.white.withOpacity(0.08),
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: const BorderSide(color: Colors.white24, width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amberAccent.withOpacity(0.4),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset('assets/drawables/logo.png',
                        width: 110, height: 110),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'بازی حکم ایرانی',
                    style: TextStyle(
                      fontSize: 22,
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
                  const SizedBox(height: 8),
                  Text('نسخه 1.0.0',
                      style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Vazirmatn',
                          fontSize: 15)),
                  const SizedBox(height: 8),
                  Text('توسعه داده شده توسط محسن فرجی',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Vazirmatn',
                          fontSize: 15)),
                  const SizedBox(height: 8),
                  Text('تمام حقوق این بازی متعلق به محسن فرجی است',
                      style: TextStyle(
                          color: Colors.white60,
                          fontFamily: 'Vazirmatn',
                          fontSize: 13)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                        ),
                        icon: const Icon(Icons.store_mall_directory_rounded),
                        label: const Text('مایکت'),
                        onPressed: () {
                          launchUrl(Uri.parse(
                              'https://myket.ir/developer/dev-76217'));
                        },
                      ),
                      const SizedBox(width: 18),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                        ),
                        icon: const Icon(Icons.code_rounded),
                        label: const Text('گیت‌هاب'),
                        onPressed: () {
                          launchUrl(Uri.parse('https://github.com/mohsen0dev'));
                        },
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
