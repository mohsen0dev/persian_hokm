import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'game/presentation/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //! حالت immersiveSticky برای پنهان‌سازی پایدار نوارهای سیستم
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  //! شفاف کردن نوار وضعیت و ناوبری
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  //! چرخش صفحه
  await SystemChrome.setPreferredOrientations([
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
  ]);

  await GetStorage.init();
  runApp(const MyApp());
}

//! کلاس اصلی
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        fontFamily: 'Vazirmatn',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      locale: Locale('fa', 'IR'),
      theme: ThemeData(
        fontFamily: 'Vazirmatn',
      ),
      //! صفحه اصلی
      home: const HomeScreen(),
    );
  }
}
