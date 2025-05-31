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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Image.asset('assets/drawables/logo.png', width: 100, height: 100),
            Text('بازی حکم ایرانی'),
            Text('نسخه 1.0.0'),
            Text('توسعه داده شده توسط محسن فرجی'),
            Text('تمام حقوق این بازی متعلق به محسن فرجی است'),
            Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  child: Text('myket'),
                  onPressed: () {
                    launchUrl(
                        Uri.parse('https://myket.ir/developer/dev-76217'));
                  },
                ),
                OutlinedButton(
                  child: Text('Github'),
                  onPressed: () {
                    launchUrl(Uri.parse('https://github.com/mohsen0dev'));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
