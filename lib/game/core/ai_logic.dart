import 'package:persian_hokm/game/models/enums.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/models/player.dart';

/// بررسی اینکه آیا کارت داده شده قوی‌ترین کارت باقی‌مانده از آن خال است یا نه
bool isStrongestCard(GameCard card, List<GameCard> playedCards) {
  final suit = card.suit;
  final playedRanks =
      playedCards.where((c) => c.suit == suit).map((c) => c.rank).toSet();
  // اگر همه کارت‌های قوی‌تر بازی شده‌اند، این کارت قوی‌ترین است
  return Rank.values
      .where((r) => r.index < card.rank.index)
      .every((r) => playedRanks.contains(r));
}

/// پیدا کردن ضعیف‌ترین کارت از یک لیست کارت
GameCard weakestCard(List<GameCard> cards) {
  return cards.reduce((a, b) => a.rank.index < b.rank.index ? b : a);
}

/// پیدا کردن قوی‌ترین کارت یا برنده از یک لیست کارت
GameCard strongestCard(List<GameCard> cards, {Suit? hokm}) {
  // اگر حکم مشخص شده و کارت حکم وجود دارد
  if (hokm != null) {
    final hokmCards = cards.where((c) => c.suit == hokm).toList();
    if (hokmCards.isNotEmpty) {
      // قوی‌ترین حکم (کمترین index یعنی بالاترین رتبه)
      return hokmCards.reduce((a, b) => a.rank.index < b.rank.index ? a : b);
    }
  }

  // در غیر این صورت، قوی‌ترین کارت بر اساس rank
  return cards.reduce((a, b) => a.rank.index < b.rank.index ? a : b);
}

/// بررسی اینکه آیا یار در دست قبلی یک خال را برید و تو هم از آن خال داری
GameCard? partnerCutSuitAndYouHaveIt({
  required Direction myDirection,
  required List<GameCard> hand,
  required List<List<GameCard>> tableHistory,
  required Suit hokm,
}) {
  if (tableHistory.isEmpty) return null;
  final lastHand = tableHistory.last;
  final leadSuit = lastHand.first.suit;
  // تعیین یار
  final partnerDir = myDirection == Direction.bottom
      ? Direction.top
      : myDirection == Direction.top
          ? Direction.bottom
          : myDirection == Direction.left
              ? Direction.right
              : Direction.left;
  final partnerCard = lastHand[partnerDir.index];
  // اگر یار حکم انداخته و خال اصلی را نداشته
  if (partnerCard.suit == hokm && partnerCard.suit != leadSuit) {
    final mySuitCards = hand.where((c) => c.suit == leadSuit).toList();
    if (mySuitCards.isNotEmpty) {
      // آیا قوی‌ترین کارت را داری؟
      final playedSuitCards = tableHistory
          .expand((l) => l)
          .where((c) => c.suit == leadSuit)
          .toList();
      for (final card in mySuitCards) {
        if (isStrongestCard(card, playedSuitCards)) {
          return card;
        }
      }
      // اگر قوی‌ترین را نداری، ضعیف‌ترین کارت را بازی کن
      return weakestCard(mySuitCards);
    }
  }
  return null;
}

/// بررسی اینکه آیا حریف کارت قوی از یک خال دارد و تو هم از آن خال داری، سعی کن آن خال را بازی نکنی
GameCard? avoidStrongOpponentSuit({
  required List<GameCard> hand,
  required List<List<GameCard>> tableHistory,
  required Suit hokm,
}) {
  for (final suit in Suit.values.where((s) => s != hokm)) {
    final mySuitCards = hand.where((c) => c.suit == suit).toList();
    if (mySuitCards.isEmpty) continue;
    final playedSuitCards =
        tableHistory.expand((l) => l).where((c) => c.suit == suit).toList();
    bool acePlayed = playedSuitCards.any((c) => c.rank == Rank.ace);
    bool kingPlayed = playedSuitCards.any((c) => c.rank == Rank.king);
    if (!acePlayed || !kingPlayed) {
      // سعی کن این خال را بازی نکنی
      continue;
    }
    // اگر مجبور شدی، ضعیف‌ترین کارت را بازی کن
    return weakestCard(mySuitCards);
  }
  return null;
}

/// بررسی اینکه آیا یک حریف قبلا یک خال غیر حکم را با حکم بریده است
Set<Suit> opponentPreviouslyCutSuitWithHokm({
  required List<List<GameCard>> tableHistory,
  required Suit hokm,
  required Direction myDirection,
  required List<Player> players,
}) {
  final cutSuits = <Suit>{};
  final myPartnerDir = myDirection == Direction.bottom
      ? Direction.top
      : myDirection == Direction.top
          ? Direction.bottom
          : myDirection == Direction.left
              ? Direction.right
              : Direction.left;

  for (final hand in tableHistory) {
    if (hand.length != 4) continue; // Sanity check

    final leadCard = hand.first;
    final winningCard = strongestCard(hand, hokm: hokm);
    final winnerPlayer = winningCard.player!;

    // Check if the winner was an opponent (not me and not my partner)
    if (winnerPlayer.direction != myDirection &&
        winnerPlayer.direction != myPartnerDir) {
      // Check if the winning card was hokm and played on a non-hokm lead suit
      if (winningCard.suit == hokm && leadCard.suit != hokm) {
        cutSuits.add(leadCard.suit);
      }
    }
  }

  return cutSuits;
}
