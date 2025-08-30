import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:as_hokme/game/presentation/widgets/screen_size_guard.dart';

class SettingsController extends GetxController {
  final box = GetStorage();

  final animationSpeed = 1.obs;
  // هوش مصنوعی: 0=مبتدی، 1=معمولی، 2=حرفه‌ای
  final aiLevel = 2.obs;
  // نحوه پخش کارت‌ها: false=تک‌تک، true=گروهی
  final dealGrouped = false.obs;
  // پس‌زمینه: 0=مشکی، 1=سفید، 2=خاکستری، 3-6=عکس
  final backgroundIndex = 0.obs;
  // طرح پشت کارت: 0=قرمز، 1=آبی، 2=سبز، 3-6=عکس
  final cardBackIndex = 3.obs;
  // گزینه فعال/غیرفعال بودن صدا
  final soundEnabled = true.obs;

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
    dealGrouped.value = box.read('dealGrouped') ?? false;
    backgroundIndex.value = box.read('backgroundIndex') ?? 0;
    cardBackIndex.value = box.read('cardBackIndex') ?? 3;
    soundEnabled.value = box.read('soundEnabled') ?? true;
  }

  void saveSettings() async {
    await box.write('animationSpeed', animationSpeed.value);
    await box.write('aiLevel', aiLevel.value);
    await box.write('dealGrouped', dealGrouped.value);
    await box.write('backgroundIndex', backgroundIndex.value);
    await box.write('cardBackIndex', cardBackIndex.value);
    await box.write('soundEnabled', soundEnabled.value);
  }

  void resetSettings() async {
    animationSpeed.value = 1;
    aiLevel.value = 2;
    dealGrouped.value = false;
    backgroundIndex.value = 0;
    cardBackIndex.value = 3;
    soundEnabled.value = true;
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
    final orientation = MediaQuery.of(context).orientation;
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
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 2,
      ),
      body: ScreenSizeGuard(
        child: Container(
          width: double.infinity,
          height: double.infinity,
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
          child: Obx(() {
            if (orientation == Orientation.portrait) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 100,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _settingsCard([
                          _sectionTitle('سرعت پخش کارت‌ها'),
                          _buildAnimationSpeedChips(),
                        ]),
                        _settingsCard([
                          _sectionTitle('نحوه پخش کارت‌ها'),
                          _buildDealModeChips(),
                        ]),
                        _settingsCard([
                          _sectionTitle('هوش مصنوعی حریفان'),
                          _buildAILevelChips(),
                        ]),
                        _settingsCard([
                          _sectionTitle('پس‌زمینه صفحه بازی'),
                          _buildBackgroundPicker(),
                        ]),
                        _settingsCard([
                          _sectionTitle('طرح پشت کارت‌ها'),
                          _buildCardBackPicker(),
                        ]),
                        _settingsCard([
                          _buildSoundSwitch(),
                        ]),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // حالت افقی: دو ستون اسکرول‌پذیر
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.only(left: 8, right: 16),
                      child: ListView(
                        children: [
                          _settingsCard([
                            _sectionTitle('سرعت پخش کارت‌ها'),
                            SizedBox(height: 14),
                            _buildAnimationSpeedChips(),
                            SizedBox(height: 14),
                          ]),
                          _settingsCard([
                            _sectionTitle('نحوه پخش کارت‌ها'),
                            SizedBox(height: 14),
                            _buildDealModeChips(),
                            SizedBox(height: 14),
                          ]),
                          _settingsCard([
                            _sectionTitle('هوش مصنوعی حریفان'),
                            SizedBox(height: 14),
                            _buildAILevelChips(),
                            SizedBox(height: 14),
                          ]),
                          _settingsCard([
                            _buildSoundSwitch(),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: ListView(
                        children: [
                          _settingsCard([
                            _sectionTitle('پس‌زمینه صفحه بازی'),
                            SizedBox(height: 5),
                            _buildBackgroundPicker(),
                          ]),
                          _settingsCard([
                            _sectionTitle('طرح پشت کارت‌ها'),
                            SizedBox(height: 5),
                            _buildCardBackPicker(),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) => Container(
        constraints: const BoxConstraints(minWidth: 220),
        child: Card(
          color: const Color(0xFF232526).withOpacity(0.92),
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Colors.white24, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      );

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8),
        child: Row(
          children: [
            Icon(Icons.tune, color: Colors.deepPurple.shade400, size: 22),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazirmatn',
                    fontSize: 16)),
          ],
        ),
      );

  Widget _buildAnimationSpeedChips() {
    final labels = ['کم', 'عادی', 'تند'];
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          3,
          (i) => ChoiceChip(
            label: Text(labels[i]),
            selected: settingsController.animationSpeed.value == i,
            onSelected: (selected) =>
                settingsController.animationSpeed.value = i,
            selectedColor: Colors.purple.shade200,
          ),
        ),
      ),
    );
  }

  Widget _buildAILevelChips() {
    final labels = ['مبتدی', 'معمولی', 'حرفه‌ای'];
    final icons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied
    ];
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          3,
          (i) => ChoiceChip(
            avatar: Icon(
              icons[i],
              color: settingsController.aiLevel.value == i
                  ? Colors.white
                  : Colors.grey,
            ),
            label: Text(labels[i]),
            selected: settingsController.aiLevel.value == i,
            onSelected: (selected) => settingsController.aiLevel.value = i,
            selectedColor: Colors.purple.shade200,
          ),
        ),
      ),
    );
  }

  /// انتخاب نحوه پخش کارت‌ها (تک‌تک/گروهی)
  Widget _buildDealModeChips() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('تک تک'),
            selected: settingsController.dealGrouped.value == false,
            onSelected: (selected) {
              if (selected) settingsController.dealGrouped.value = false;
            },
            selectedColor: Colors.purple.shade200,
          ),
          ChoiceChip(
            label: const Text('گروهی'),
            selected: settingsController.dealGrouped.value == true,
            onSelected: (selected) {
              if (selected) settingsController.dealGrouped.value = true;
            },
            selectedColor: Colors.purple.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPicker() {
    final selectedColor = Colors.purple.shade800;

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
    final selectedColor = Colors.purple.shade800;
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
                      // color: settingsController.cardBackColors[i],
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
                            : Colors.grey,
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

  Widget _buildSoundSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.volume_up, color: Colors.deepPurple.shade400, size: 22),
            const SizedBox(width: 8),
            const Text('صدا فعال باشد',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Vazirmatn',
                    fontSize: 16)),
          ],
        ),
        Obx(() => Switch(
              value: settingsController.soundEnabled.value,
              onChanged: (val) => settingsController.soundEnabled.value = val,
            )),
      ],
    );
  }
}
