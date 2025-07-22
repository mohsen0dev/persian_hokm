import 'package:get/get.dart';
import 'package:persian_hokm/game/models/card.dart';

/// مدیریت نوبت بازیکن و بررسی امکان بازی کارت
class TurnManager {
  /// بررسی امکان بازی کردن کارت توسط بازیکن
  static bool canPlayCard({
    required bool isBottomPlayerTurn,
    required String currentPlayer,
    required Map<String, GameCard> tableCards,
    required Suit? firstSuit,
    required Map<String, RxList<GameCard>> playerCards,
    required Function(String) showSnackBar,
    required GameCard card,
  }) {
    if (!isBottomPlayerTurn && currentPlayer != 'bottom') {
      return true;
    }
    if (!isBottomPlayerTurn) {
      showSnackBar('نوبت شما نیست');
      return false;
    }
    if (firstSuit == null) {
      return true;
    }
    if (card.suit != firstSuit) {
      final hasFirstSuitCard =
          playerCards['bottom']!.any((c) => c.suit == firstSuit);
      if (hasFirstSuitCard) {
        showSnackBar('کارت  نامعتبر !!!');
        return false;
      }
    }
    return true;
  }

  /// بررسی فعال بودن کارت برای بازی توسط بازیکن
  static bool isCardPlayable({
    required bool isBottomPlayerTurn,
    required Map<String, GameCard> tableCards,
    required Suit? firstSuit,
    required Map<String, RxList<GameCard>> playerCards,
    required GameCard card,
  }) {
    if (!isBottomPlayerTurn) {
      return false;
    }
    if (firstSuit == null) {
      return true;
    }
    if (card.suit != firstSuit) {
      final hasFirstSuitCard =
          playerCards['bottom']!.any((c) => c.suit == firstSuit);
      if (hasFirstSuitCard) {
        return false;
      }
    }
    return true;
  }
}
