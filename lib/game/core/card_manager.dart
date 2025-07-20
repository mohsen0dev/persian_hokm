import 'package:get/get.dart';
import 'package:persian_hokm/game/models/enums.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/models/player.dart';

/// مدیریت کارت‌های بازیکنان و همگام‌سازی دست‌ها
class CardManager {
  /// همگام‌سازی دست بازیکنان با رابط کاربری
  static void syncHandsWithUI({
    required Map<String, RxList<GameCard>> playerCards,
    required List<List<GameCard>> hands,
    required List<Player> players,
  }) {
    for (var pos in ['bottom', 'right', 'top', 'left']) {
      playerCards[pos]?.clear();
    }
    for (int i = 0; i < 4; i++) {
      final dir = Direction.values[i];
      final pos = _directionToString(dir);
      playerCards[pos]?.addAll(hands[i]);
      if (players.length == 4) {
        players[i].hand.clear();
        players[i].hand.addAll(hands[i]);
      }
    }
    sortBottomPlayerCards(playerCards: playerCards);
  }

  /// مرتب‌سازی کارت‌های بازیکن پایین
  static void sortBottomPlayerCards({
    required Map<String, RxList<GameCard>> playerCards,
  }) {
    if (playerCards['bottom']?.isNotEmpty ?? false) {
      playerCards['bottom']?.sort((a, b) {
        final suitOrder = {
          Suit.hearts: 0,
          Suit.clubs: 1,
          Suit.diamonds: 2,
          Suit.spades: 3,
        };
        if (a.suit != b.suit) {
          return suitOrder[a.suit]!.compareTo(suitOrder[b.suit]!);
        }
        return a.rank.index.compareTo(b.rank.index);
      });
    }
  }

  /// حذف کارت از دست بازیکن
  static void removeCardFromPlayer({
    required GameCard card,
    required String currentPlayer,
    required Map<String, RxList<GameCard>> playerCards,
    required List<List<GameCard>> hands,
    required List<Player> players,
  }) {
    final dir = Direction.values
        .firstWhere((d) => _directionToString(d) == currentPlayer);
    playerCards[currentPlayer]
        ?.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    hands[dir.index]
        .removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    if (players.length == 4) {
      players[dir.index]
          .hand
          .removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    }
  }

  /// تبدیل جهت بازیکن به رشته موقعیت
  static String _directionToString(Direction dir) {
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
}
