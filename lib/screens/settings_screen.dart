import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // late SharedPreferences _prefs;
  double _gameSpeed = 1000; // Default 1 second
  Color _backgroundColor = Colors.white;
  Color _teammateCardColor = Colors.red;
  Color _opponentCardColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    // _loadSettings();
  }

  // Future<void> _loadSettings() async {
  //   _prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _gameSpeed = _prefs.getDouble('gameSpeed') ?? 1000;
  //     _backgroundColor =
  //         Color(_prefs.getInt('backgroundColor') ?? Colors.white.value);
  //     _teammateCardColor =
  //         Color(_prefs.getInt('teammateCardColor') ?? Colors.red.value);
  //     _opponentCardColor =
  //         Color(_prefs.getInt('opponentCardColor') ?? Colors.blue.value);
  //   });
  // }

  // Future<void> _saveSettings() async {
  //   await _prefs.setDouble('gameSpeed', _gameSpeed);
  //   await _prefs.setInt('backgroundColor', _backgroundColor.value);
  //   await _prefs.setInt('teammateCardColor', _teammateCardColor.value);
  //   await _prefs.setInt('opponentCardColor', _opponentCardColor.value);
  // }

  Future<void> _resetToDefault() async {
    setState(() {
      _gameSpeed = 1000;
      _backgroundColor = Colors.white;
      _teammateCardColor = Colors.red;
      _opponentCardColor = Colors.blue;
    });
    // await _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات بازی'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSpeedSlider(),
          const SizedBox(height: 24),
          _buildColorPicker(
            'رنگ پس زمینه',
            _backgroundColor,
            (color) {
              setState(() => _backgroundColor = color);
              // _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          _buildColorPicker(
            'رنگ کارت یار',
            _teammateCardColor,
            (color) {
              setState(() => _teammateCardColor = color);
              // _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          _buildColorPicker(
            'رنگ کارت حریف',
            _opponentCardColor,
            (color) {
              setState(() => _opponentCardColor = color);
              // _saveSettings();
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _resetToDefault,
            child: const Text('بازگشت به تنظیمات پیش‌فرض'),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سرعت بازی',
          style: TextStyle(fontSize: 18),
        ),
        Slider(
          value: _gameSpeed,
          min: 500,
          max: 3000,
          divisions: 5,
          label: '${(_gameSpeed / 1000).toStringAsFixed(1)} ثانیه',
          onChanged: (value) {
            setState(() => _gameSpeed = value);
            // _saveSettings();
          },
        ),
        Text(
          '${(_gameSpeed / 1000).toStringAsFixed(1)} ثانیه',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    String title,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.purple,
            Colors.orange,
            Colors.white,
            Colors.black,
          ].map((color) {
            return GestureDetector(
              onTap: () => onColorChanged(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentColor == color ? Colors.black : Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
