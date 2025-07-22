import 'package:audioplayers/audioplayers.dart';

/// مدیریت پخش صداها در بازی
/// این کلاس مسئول پخش و مدیریت منابع صوتی است
class SoundManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool enabled = true; // پیش‌فرض فعال

  /// پخش صدای مورد نظر با نام داده شده
  Future<void> play(String name) async {
    if (!enabled) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('songs/$name'));
    } catch (_) {}
  }

  /// پاکسازی منابع صوتی
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
  }
}
