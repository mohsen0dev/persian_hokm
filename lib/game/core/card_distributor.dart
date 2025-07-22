import 'dart:async';
import 'package:get/get.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/models/enums.dart';
import 'package:persian_hokm/game/models/player.dart';
import 'package:persian_hokm/game/core/sound_manager.dart';
import 'package:persian_hokm/game/presentation/widgets/animated_card.dart';

/// مدیریت توزیع کارت‌ها بین بازیکنان
class CardDistributor {
  final SoundManager soundManager;

  CardDistributor({required this.soundManager});

  /// توزیع کارت برای تعیین حاکم
  Future<String?> distributeCardsForHakem({
    required List<GameCard> cards,
    required Map<String, RxList<GameCard>> playerCards,
    required RxList<dynamic> animatedCards,
    required bool Function() isActive,
    required void Function() update,
    required Future<void> Function(String hakem) onAceFound,
  }) async {
    int currentCardIndex = 0;
    final distributionOrder = ['bottom', 'right', 'top', 'left'];
    int currentPlayerIndex = 0;
    while (currentCardIndex < cards.length) {
      if (!isActive()) return null;
      final currentCard = cards[currentCardIndex];
      final currentPlayer = distributionOrder[currentPlayerIndex];
      soundManager.play('pakhsh.mp3');
      final animData =
          AnimatedCard(card: currentCard, targetPosition: currentPlayer);
      animatedCards.add(animData);
      // update();
      await Future.delayed(const Duration(milliseconds: 350));
      if (!isActive()) return null;
      playerCards[currentPlayer]?.add(currentCard);
      animatedCards.removeWhere((a) => a.key == animData.key);
      cards.removeAt(currentCardIndex);
      // update();
      await Future.delayed(const Duration(milliseconds: 60));
      if (!isActive()) return null;
      if (currentCard.rank == Rank.ace) {
        await onAceFound(currentPlayer);
        return currentPlayer;
      }
      currentPlayerIndex = (currentPlayerIndex + 1) % 4;
    }
    return null;
  }

  /// توزیع مرحله‌ای کارت‌ها به بازیکنان
  Future<void> dealCardsStepByStep({
    required int numCards,
    required List<Direction> order,
    required List<GameCard> deck,
    required List<List<GameCard>> hands,
    required List<Player> players,
    required Map<String, RxList<GameCard>> playerCards,
    required List<GameCard> cards,
    required RxList<dynamic> animatedCards,
    required void Function() update,
  }) async {
    for (final dir in order) {
      for (int i = 0; i < numCards; i++) {
        final card = deck.removeAt(0);
        soundManager.play('pakhsh.mp3');
        final animData =
            AnimatedCard(card: card, targetPosition: _directionToString(dir));
        animatedCards.add(animData);
        // update();
        await Future.delayed(const Duration(milliseconds: 350));
        hands[dir.index].add(card);
        card.player = players.isNotEmpty ? players[dir.index] : null;
        playerCards[_directionToString(dir)]?.add(card);
        cards.removeAt(0);
        animatedCards.removeWhere((a) => a.key == animData.key);
        // update();
        await Future.delayed(const Duration(milliseconds: 60));
      }
    }
  }

  /// تبدیل جهت بازیکن به رشته موقعیت
  String _directionToString(Direction dir) {
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
