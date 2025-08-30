import 'package:flutter/material.dart';
import 'package:as_hokme/game/presentation/utils/ui_helper.dart';
import 'package:as_hokme/game/presentation/widgets/screen_size_guard.dart';
import 'package:url_launcher/url_launcher.dart';

class AbuteMeScreen extends StatelessWidget {
  const AbuteMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    final mainInfo = Column(
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
          child: Image.asset(
            'assets/drawables/logo.png',
            width: 110,
            height: 110,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'بازی آس حکم',
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
        Text(
          'نسخه ${UIHelper.version}',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Vazirmatn',
            fontSize: 15,
          ),
        ),
      ],
    );

    final details = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'توسعه داده شده توسط محسن فرجی',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Vazirmatn',
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'از حمایت شما متشکریم',
          style: TextStyle(
            color: Colors.amberAccent,
            fontFamily: 'Vazirmatn',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                'بازی آس حکم یک بازی کارتی محبوب ایرانی است که با گرافیک زیبا و هوش مصنوعی پیشرفته طراحی شده است:',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Vazirmatn',
                  fontSize: 14,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology, color: Colors.amberAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'هوش مصنوعی پیشرفته',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_up, color: Colors.amberAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'صداگذاری حرفه‌ای',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.animation, color: Colors.amberAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'انیمیشن‌های جذاب',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Vazirmatn',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('درباره ما'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF232526), Color(0xFF414345)],
          ),
        ),
        child: ScreenSizeGuard(
          child: Center(
            child: SizedBox(
              width: 650,
              child: Card(
                color: Colors.white.withOpacity(0.08),
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: const BorderSide(color: Colors.white24, width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  child: orientation == Orientation.portrait
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            mainInfo,
                            const SizedBox(height: 8),
                            details,
                            MyketButton(),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                mainInfo,
                                SizedBox(height: 8),
                                MyketButton(),
                              ],
                            )),
                            const SizedBox(width: 32),
                            Expanded(child: details),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyketButton extends StatelessWidget {
  const MyketButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          icon: const Icon(Icons.store_mall_directory_rounded),
          label: const Text('امتیاز برنامه'),
          onPressed: () async {
            final mayket = Uri.parse(
              'myket://details?id=com.gmail.farajiMohsen.as_hokm',
            );

            if (await canLaunchUrl(mayket)) {
              await launchUrl(mayket, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                UIHelper.showSnackBar(context, 'اپلیکیشن مایکت پیدا نشد');
              }
            }
          },
        ),
        const SizedBox(width: 18),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple.shade400,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          icon: const Icon(Icons.code_rounded),
          label: const Text('برنامه های من'),
          //
          onPressed: () async {
            final mayket = Uri.parse(
              'myket://developer/com.gmail.farajiMohsen.service_car',
            );
            final web = Uri.parse(
                'https://myket.ir/developer/com.gmail.farajiMohsen.service_car');

            if (await canLaunchUrl(mayket)) {
              await launchUrl(mayket, mode: LaunchMode.externalApplication);
            } else if (await canLaunchUrl(web)) {
              await launchUrl(web, mode: LaunchMode.externalApplication);
            } else {
              if (context.mounted) {
                UIHelper.showSnackBar(context, 'اپلیکیشن مایکت پیدا نشد');
              }
            }
          },
        ),
      ],
    );
  }
}
