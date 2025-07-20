import 'package:persian_hokm/game/models/enums.dart';

/// توابع کمکی بازی
class GameUtils {
  /// دریافت نام بازیکن بر اساس موقعیت
  static String getPlayerName(String position) {
    switch (position) {
      case 'bottom':
        return 'شما';
      case 'right':
        return 'حریف1';
      case 'top':
        return 'یار شما';
      case 'left':
        return 'حریف2';
      default:
        return '';
    }
  }

  /// تبدیل جهت بازیکن به رشته موقعیت
  static String directionToString(Direction dir) {
    switch (dir) {
      case Direction.bottom:
        return 'bottom';
      case Direction.right:
        return 'right';
      case Direction.top:
        return 'top';
      case Direction.left:
        return 'left';
    }
  }

  /// تبدیل رشته موقعیت به جهت بازیکن
  static Direction stringToDirection(String pos) {
    switch (pos) {
      case 'bottom':
        return Direction.bottom;
      case 'right':
        return Direction.right;
      case 'top':
        return Direction.top;
      case 'left':
        return Direction.left;
      default:
        return Direction.bottom;
    }
  }
}
