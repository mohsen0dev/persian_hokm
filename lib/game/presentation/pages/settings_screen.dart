import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final box = GetStorage();

  final animationSpeed = 1.obs;
  // هوش مصنوعی: 0=مبتدی، 1=معمولی، 2=حرفه‌ای
  final aiLevel = 2.obs;
  // پس‌زمینه: 0=مشکی، 1=سفید، 2=خاکستری، 3-6=عکس
  final backgroundIndex = 0.obs;
  // طرح پشت کارت: 0=قرمز، 1=آبی، 2=سبز، 3-6=عکس
  final cardBackIndex = 3.obs;

  final List<Color> backgroundColors = [
    Colors.black,
    Colors.white,
    Colors.grey.shade700
  ];
  final List<String> backgroundImages = [
    'assets/drawables/background.jpg',
    'assets/drawables/background2.jpg',
    'assets/drawables/background3.jpg',
    'assets/drawables/background4.jpg',
  ];
  final List<Color> cardBackColors = [Colors.red, Colors.blue, Colors.green];
  final List<String> cardBackImages = [
    'assets/drawables/cardBack1.png',
    'assets/drawables/cardBack2.png',
    'assets/drawables/cardBack3.png',
    'assets/drawables/cardBack4.png',
  ];

  @override
  void onInit() {
    super.onInit();
    animationSpeed.value = box.read('animationSpeed') ?? 1;
    aiLevel.value = box.read('aiLevel') ?? 2;
    backgroundIndex.value = box.read('backgroundIndex') ?? 0;
    cardBackIndex.value = box.read('cardBackIndex') ?? 3;
  }

  void saveSettings() async {
    await box.write('animationSpeed', animationSpeed.value);
    await box.write('aiLevel', aiLevel.value);
    await box.write('backgroundIndex', backgroundIndex.value);
    await box.write('cardBackIndex', cardBackIndex.value);
  }

  void resetSettings() async {
    animationSpeed.value = 1;
    aiLevel.value = 2;
    backgroundIndex.value = 0;
    cardBackIndex.value = 3;
    await box.erase();
    saveSettings();
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  // سرعت انیمیشن: 0=کم، 1=عادی، 2=تند
  final settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    settingsController.saveSettings();
                    Get.back();
                  },
                  icon: const Icon(Icons.save),
                ),
                IconButton(
                  onPressed: () {
                    settingsController.resetSettings();
                  },
                  icon: const Icon(Icons.restore),
                ),
              ],
            ),
            const Text('تنظیمات بازی'),
            SizedBox(width: 80),
          ],
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _sectionTitle('سرعت پخش کارت‌ها'),
            _buildAnimationSpeedChips(),
            const Divider(height: 24),
            _sectionTitle('هوش مصنوعی حریفان'),
            _buildAILevelChips(),
            const Divider(height: 24),
            _sectionTitle('پس‌زمینه صفحه بازی'),
            _buildBackgroundPicker(),
            const Divider(height: 24),
            _sectionTitle('طرح پشت کارت‌ها'),
            _buildCardBackPicker(),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _buildAnimationSpeedChips() {
    final labels = ['کم', 'عادی', 'تند'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          3,
          (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  label: Text(labels[i]),
                  selected: settingsController.animationSpeed.value == i,
                  onSelected: (selected) =>
                      settingsController.animationSpeed.value = i,
                  selectedColor: Colors.purple.shade200,
                ),
              )),
    );
  }

  Widget _buildAILevelChips() {
    final labels = ['مبتدی', 'معمولی', 'حرفه‌ای'];
    final icons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          3,
          (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ChoiceChip(
                  avatar: Icon(icons[i],
                      color: settingsController.aiLevel.value == i
                          ? Colors.white
                          : Colors.grey),
                  label: Text(labels[i]),
                  selected: settingsController.aiLevel.value == i,
                  onSelected: (selected) =>
                      settingsController.aiLevel.value = i,
                  selectedColor: Colors.purple.shade200,
                ),
              )),
    );
  }

  Widget _buildBackgroundPicker() {
    final selectedColor = Colors.purple.shade200;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...List.generate(
            settingsController.backgroundColors.length,
            (i) => GestureDetector(
                  onTap: () => settingsController.backgroundIndex.value = i,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: settingsController.backgroundColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: settingsController.backgroundIndex.value == i
                            ? selectedColor
                            : Colors.grey,
                        width: 3,
                      ),
                    ),
                    child: settingsController.backgroundIndex.value == i
                        ? Icon(Icons.check_circle_outlined,
                            color: selectedColor, size: 25)
                        : null,
                  ),
                )),
        ...List.generate(
            settingsController.backgroundImages.length,
            (i) => GestureDetector(
                  onTap: () => settingsController.backgroundIndex.value =
                      i + settingsController.backgroundColors.length,
                  child: Container(
                    width: 70,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: settingsController.backgroundIndex.value ==
                                i + settingsController.backgroundColors.length
                            ? selectedColor
                            : Colors.grey,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image:
                            AssetImage(settingsController.backgroundImages[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: settingsController.backgroundIndex.value ==
                            i + settingsController.backgroundColors.length
                        ? ColoredBox(
                            color: Colors.white.withOpacity(0.5),
                            child: Icon(Icons.check_circle_outlined,
                                color: selectedColor, size: 30),
                          )
                        : null,
                  ),
                )),
      ],
    );
  }

  Widget _buildCardBackPicker() {
    final selectedColor = Colors.purple.shade200;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...List.generate(
            settingsController.cardBackColors.length,
            (i) => GestureDetector(
                  onTap: () => settingsController.cardBackIndex.value = i,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: settingsController.cardBackColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: settingsController.cardBackIndex.value == i
                            ? selectedColor
                            : Colors.grey,
                        width: 3,
                      ),
                    ),
                    child: settingsController.cardBackIndex.value == i
                        ? Icon(Icons.check_circle_outlined,
                            color: selectedColor, size: 25)
                        : null,
                  ),
                )),
        ...List.generate(
            settingsController.cardBackImages.length,
            (i) => GestureDetector(
                  onTap: () => settingsController.cardBackIndex.value =
                      i + settingsController.cardBackColors.length,
                  child: Container(
                    width: 45,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: settingsController.cardBackIndex.value ==
                                i + settingsController.cardBackColors.length
                            ? selectedColor
                            : Colors.grey.shade200,
                        width: 3,
                      ),
                      image: DecorationImage(
                        image: AssetImage(settingsController.cardBackImages[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: settingsController.cardBackIndex.value ==
                            i + settingsController.cardBackColors.length
                        ? ColoredBox(
                            color: Colors.white.withOpacity(0.5),
                            child: Icon(Icons.check_circle_outlined,
                                color: selectedColor, size: 30),
                          )
                        : null,
                  ),
                )),
      ],
    );
  }
}
