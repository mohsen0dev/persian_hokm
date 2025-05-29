import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/models/card.dart';
import 'package:persian_hokm/widgets/card_widget.dart';
import 'package:persian_hokm/screens/settings_screen.dart';

// -------------------- منطق بازی حکم (تبدیل شده از کاتلین) --------------------

/// جهت‌های بازی
///
/// جهت‌ها به ترتیب: پایین (بازیکن انسانی)، راست، بالا، چپ
enum Direction {
  bottom,
  right,
  top,
  left,
}

/// کلاس پایه بازیکن
abstract class Player {
  final String name;
  final List<GameCard> hand = [];
  late Team team;
  late Direction direction;

  Player(this.name, List<GameCard> cards, this.direction) {
    addHand(cards);
  }

  /// اضافه کردن دست بازیکن
  void addHand(List<GameCard> newHand) {
    hand.clear();
    hand.addAll(newHand);
  }

  /// متد بازی کردن کارت (باید توسط زیرکلاس‌ها پیاده‌سازی شود)
  GameCard play({
    //! جدول
    required List<GameCard> table,
    //! جدول های قبلی
    required List<List<GameCard>> tableHistory,
    //! تیم‌ها
    required List<Team> teams,
    //! خال حکم
    required Suit hokm,
  });

  /// انتخاب خال حکم توسط هوش مصنوعی
  Suit determineHokm() {
    if (hand.isEmpty) throw Exception("Hand is empty");

    // دیکشنری امتیازدهی کارت‌ها (به صورت تاکتیکی)
    final rankScore = {
      Rank.ace: 10,
      Rank.king: 8,
      Rank.queen: 7,
      Rank.jack: 6,
      Rank.ten: 5,
      Rank.nine: 4,
      Rank.eight: 3,
      Rank.seven: 2,
      Rank.six: 1,
      Rank.five: 1,
      Rank.four: 0,
      Rank.three: 0,
      Rank.two: 0,
    };
    //! امتیازدهی برای خال‌ها
    final Map<Suit, int> suitScore = {};
    //! تعداد کارت‌های هر خال
    final Map<Suit, int> suitCount = {};

    //! محاسبه امتیاز و تعداد کارت‌های هر خال
    for (final card in hand) {
      suitCount[card.suit] = (suitCount[card.suit] ?? 0) + 1;
      suitScore[card.suit] =
          (suitScore[card.suit] ?? 0) + (rankScore[card.rank] ?? 0);
    }

    // ترکیب امتیاز و تعداد برای رتبه‌بندی هوشمند
    final scoredSuits = suitScore.entries.map((entry) {
      final suit = entry.key;
      final score = entry.value;
      final count = suitCount[suit]!;
      final total =
          score + (count * 2); // تعداد ×۲ برای تأکید بر داشتن کارت بیشتر
      return MapEntry(suit, total);
    }).toList();

    // مرتب‌سازی خال‌ها از بهترین به ضعیف‌ترین
    scoredSuits.sort((a, b) => b.value.compareTo(a.value));

    // برگرداندن خال با بیشترین امتیاز ترکیبی
    return scoredSuits.first.key;
  }
}

/// بازیکن هوش مصنوعی
class PlayerAI extends Player {
  //! سطح هوش مصنوعی
  final int aiLevel;
  //! آیا بازیکن همکار است؟
  final bool isPartner;

  PlayerAI(
    //! نام بازیکن
    String name,
    //! جهت بازیکن
    Direction direction,
    //! دست بازیکن
    List<GameCard> cards, {
    //! سطح هوش مصنوعی
    required this.aiLevel,
    //! آیا بازیکن همکار است؟
    required this.isPartner,
  }) : super(name, cards, direction);

  @override
  GameCard play({
    required List<GameCard> table,
    required List<List<GameCard>> tableHistory,
    required List<Team> teams,
    required Suit hokm,
  }) {
    //! سطح هوش مصنوعی موثر
    final effectiveLevel = isPartner ? 2 : aiLevel;
    switch (effectiveLevel) {
      case 0:
        return _basicPlay(table, hokm);
      case 1:
        return _intermediatePlay(table, hokm);
      case 2:
        return _advancedPlay(table, hokm, tableHistory, teams);
      default:
        return _advancedPlay(table, hokm, tableHistory, teams);
    }
  }

  GameCard _basicPlay(List<GameCard> table, Suit hokm) {
    //! اگر جدول خالی است
    if (table.isEmpty) {
      //! کارت‌های غیر حکم
      final nonHokms = hand.where((c) => c.suit != hokm).toList();
      return nonHokms.isNotEmpty ? _strongest(nonHokms) : _strongest(hand);
    }

    //! کارت‌های هم خال
    final sameSuit = _sameSuitCards(table.first);
    if (sameSuit.isNotEmpty) {
      return _weakest(sameSuit);
    }

    //! کارت‌های حکم
    final hokms = _suitCards(hokm);
    return hokms.isNotEmpty ? _weakest(hokms) : _weakest(hand);
  }

  GameCard _intermediatePlay(List<GameCard> table, Suit hokm) {
    //! اگر جدول خالی است
    if (table.isEmpty) return _strongest(hand);

    //! کارت‌های هم خال
    final sameSuit = _sameSuitCards(table.first);
    if (sameSuit.isNotEmpty) {
      final maxOnTable =
          _strongest(table.where((c) => c.suit == table.first.suit).toList());
      final winning =
          sameSuit.where((c) => c.rank.index > maxOnTable.rank.index).toList();
      return winning.isNotEmpty ? _weakest(winning) : _weakest(sameSuit);
    }

    final hokms = _suitCards(hokm);
    return hokms.isNotEmpty ? _strongest(hokms) : _weakest(hand);
  }

  GameCard _advancedPlay(
    List<GameCard> table,
    Suit hokm,
    List<List<GameCard>> tableHistory,
    List<Team> teams,
  ) {
    // اگر نفر اول هستیم (table خالی است)
    if (table.isEmpty) {
      // دست اول (۱۳ کارت)
      if (hand.length == 13) {
        // اولویت ۱: آس غیر حکم
        final nonHokmAces =
            hand.where((c) => c.suit != hokm && c.rank == Rank.ace).toList();
        if (nonHokmAces.isNotEmpty) {
          print('یک- بازی طبق اولویت ۱: آس غیر حکم');
          return nonHokmAces.first;
        }
        // اولویت ۲: شاه غیر حکم
        final nonHokmKings =
            hand.where((c) => c.suit != hokm && c.rank == Rank.king).toList();
        if (nonHokmKings.isNotEmpty) {
          print('یک- بازی طبق اولویت ۲: شاه غیر حکم');
          final king = nonHokmKings.first;
          final sameSuitCards = hand.where((c) => c.suit == king.suit).toList();
          return weakestCard(sameSuitCards);
        }
        // اولویت ۳: خال غیر حکم با ۳ یا کمتر کارت
        final nonHokmSuits = Suit.values.where((s) => s != hokm);
        for (final suit in nonHokmSuits) {
          final suitCards = hand.where((c) => c.suit == suit).toList();
          if (suitCards.length <= 3 && suitCards.isNotEmpty) {
            print('یک- بازی طبق اولویت ۳: خال غیر حکم با ۳ یا کمتر کارت');
            return weakestCard(suitCards);
          }
        }
        // اولویت ۴: ضعیف‌ترین کارت غیر حکم
        final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
        if (nonHokmCards.isNotEmpty) {
          print('یک- بازی طبق اولویت ۴: ضعیف‌ترین کارت غیر حکم');
          return weakestCard(nonHokmCards);
        }
        // اگر فقط حکم داری، ضعیف‌ترین حکم را بازی کن
        print('یک- بازی طبق اولویت ۵: فقط حکم داری، ضعیف‌ترین حکم بازی می‌شود');
        return weakestCard(hand);
      } else {
        // دست‌های بعدی (کمتر از ۱۳ کارت)
        // اولویت ۱: آس غیر حکم
        final nonHokmAces =
            hand.where((c) => c.suit != hokm && c.rank == Rank.ace).toList();
        if (nonHokmAces.isNotEmpty) {
          print('دو- بازی طبق اولویت ۱: آس غیر حکم (دست‌های بعدی)');
          return nonHokmAces.first;
        }
        // اولویت ۲: قوی‌ترین کارت‌های حکم که قطعا برنده‌اند
        final playedCards = tableHistory.expand((l) => l).toList() + table;
        final playedHokmRanks = playedCards
            .where((c) => c.suit == hokm)
            .map((c) => c.rank)
            .toList();
        final myHokmCards = hand.where((c) => c.suit == hokm).toList();
        for (final card in myHokmCards) {
          bool isStrongest = Rank.values
              .where((r) => r.index < card.rank.index)
              .every((r) => playedHokmRanks.contains(r));
          if (isStrongest) {
            print('دو- بازی طبق اولویت ۲: قوی‌ترین کارت حکم که قطعا برنده است');
            return card;
          }
        }
        // اولویت ۳: قوی‌ترین کارت غیر حکم که قطعا برنده است
        if (hand.length > 7 && hand.length < 13) {
          for (final suit in Suit.values.where((s) => s != hokm)) {
            final mySuitCards = hand.where((c) => c.suit == suit).toList();
            if (mySuitCards.isEmpty) continue;
            final playedSuitRanks = playedCards
                .where((c) => c.suit == suit)
                .map((c) => c.rank)
                .toList();
            for (final card in mySuitCards) {
              bool isStrongest = Rank.values
                  .where((r) => r.index < card.rank.index)
                  .every((r) => playedSuitRanks.contains(r));
              if (isStrongest) {
                print(
                    'دو- بازی طبق اولویت ۳: قوی‌ترین کارت غیر حکم که قطعا برنده است');
                return card;
              }
            }
          }
        }
        // اولویت ۴: اگر یارت خالی را برید و تو هم آن خال را داری
        final partnerCard = partnerCutSuitAndYouHaveIt(
          myDirection: direction,
          hand: hand,
          tableHistory: tableHistory,
          hokm: hokm,
        );
        if (partnerCard != null) {
          print(
              'دو- بازی طبق اولویت ۴: یار خالی را برید و تو هم آن خال را داری');
          return partnerCard;
        }
        // اولویت ۴.۵: اگر نفر اول هستی و یار در دست قبلی یک خال غیر حکم را رد کرده، آن خال را بازی کن
        if (tableHistory.isNotEmpty) {
          final lastHand = tableHistory.last;
          final leadSuit = lastHand.first.suit;
          final partnerDir = direction == Direction.bottom
              ? Direction.top
              : direction == Direction.top
                  ? Direction.bottom
                  : direction == Direction.left
                      ? Direction.right
                      : Direction.left;
          final partnerCard = lastHand[partnerDir.index];
          // اگر یار خال leadSuit را نداشته و حکم نزده
          if (partnerCard.suit != leadSuit && partnerCard.suit != hokm) {
            final mySuitCards = hand.where((c) => c.suit == leadSuit).toList();
            if (mySuitCards.isNotEmpty) {
              print(
                  'دو- بازی طبق اولویت ۴.۵: یار خال را رد کرده، آن خال را بازی کن');
              return weakestCard(mySuitCards);
            }
          }
        }
        // اولویت ۴.۷: اگر یار در دست قبلی یک کارت غیر حکم را که برنده بوده و آن خال را نداشته و برش نزده، ضعیف‌ترین کارت آن خال را بازی کن تا یار بتواند آن را برش بزند
        if (tableHistory.isNotEmpty) {
          final lastHand = tableHistory.last;
          final leadSuit = lastHand.first.suit;
          final partnerDir = direction == Direction.bottom
              ? Direction.top
              : direction == Direction.top
                  ? Direction.bottom
                  : direction == Direction.left
                      ? Direction.right
                      : Direction.left;
          final partnerCard = lastHand[partnerDir.index];
          // اگر یار خال leadSuit را نداشته و حکم نزده و کارت برنده بوده
          if (partnerCard.suit != leadSuit && partnerCard.suit != hokm) {
            // آیا کارت یار قوی‌ترین کارت باقی‌مانده آن خال بوده؟
            final playedSuitCards = tableHistory
                .expand((l) => l)
                .where((c) => c.suit == leadSuit)
                .toList();
            if (isStrongestCard(partnerCard, playedSuitCards)) {
              final mySuitCards =
                  hand.where((c) => c.suit == leadSuit).toList();
              if (mySuitCards.isNotEmpty) {
                print(
                    'دو- بازی طبق اولویت ۴.۷: یار کارت برنده خال غیر حکم را رد کرده، آن خال را بازی کن تا یار برش بزند');
                return weakestCard(mySuitCards);
              }
            }
          }
        }
        // اولویت ۵: اگر حریف قبلاً یک خال را با حکم بریده، آن خال را بازی نکن
        final cutSuits = opponentPreviouslyCutSuitWithHokm(
          tableHistory: tableHistory,
          hokm: hokm,
          myDirection: direction,
          players: teams.expand((t) => [t.playerA, t.playerB]).toList(),
        );
        for (final suit in cutSuits) {
          final mySuitCards = hand.where((c) => c.suit == suit).toList();
          if (mySuitCards.isNotEmpty) {
            // اگر کارت دیگری داری، آن خال را بازی نکن
            final otherSuits = hand.where((c) => c.suit != suit).toList();
            if (otherSuits.isNotEmpty) {
              print(
                  'دو- بازی طبق اولویت ۵: حریف قبلاً این خال را بریده، آن خال را بازی نکن');
              return weakestCard(otherSuits);
            }
          }
        }
        // اولویت ۶: ضعیف‌ترین کارت غیر حکم
        final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
        if (nonHokmCards.isNotEmpty) {
          print('دو- بازی طبق اولویت ۶: ضعیف‌ترین کارت غیر حکم');
          return weakestCard(nonHokmCards);
        }
        // اگر فقط حکم داری، ضعیف‌ترین حکم را بازی کن
        print('ئو- بازی طبق اولویت ۷: فقط حکم داری، ضعیف‌ترین حکم بازی می‌شود');
        return weakestCard(hand);
      }
    } // --- منطق نفر دوم (table.length == 1) ---
    else if (table.length == 1) {
      // نفر دوم هستی
      final firstCard = table.first;
      final sameSuitCards =
          hand.where((c) => c.suit == firstCard.suit).toList();
      // ۱. اگر آس همان خال را داری و کارت روی میز غیرحکم است، آس را بازی کن
      if (sameSuitCards.any((c) => c.rank == Rank.ace) &&
          firstCard.suit != hokm) {
        // نفر دوم: آس همان خال را داری و کارت روی میز غیرحکم است، آس را بازی کن
        return sameSuitCards.firstWhere((c) => c.rank == Rank.ace);
      }
      // ۲. اگر شاه همان خال را داری و آس آن خال قبلاً بازی شده، شاه را بازی کن
      if (sameSuitCards.any((c) => c.rank == Rank.king)) {
        final playedSuitRanks = tableHistory
            .expand((l) => l)
            .where((c) => c.suit == firstCard.suit)
            .map((c) => c.rank)
            .toList();
        if (playedSuitRanks.contains(Rank.ace)) {
          // نفر دوم: شاه همان خال را داری و آس قبلاً بازی شده، شاه را بازی کن
          return sameSuitCards.firstWhere((c) => c.rank == Rank.king);
        }
      }
      // ۳. اگر کارت قوی‌تر همان خال را داری، ضعیف‌ترین کارت برنده همان خال را بازی کن
      if (sameSuitCards.isNotEmpty) {
        final maxOnTable = strongestCard([firstCard]);
        final winning = sameSuitCards
            .where((c) => c.rank.index < maxOnTable.rank.index)
            .toList();
        if (winning.isNotEmpty) {
          // نفر دوم: کارت قوی‌تر داری، ضعیف‌ترین کارت برنده همان خال را بازی کن
          return weakestCard(winning);
        } else {
          // نفر دوم: فقط کارت ضعیف همان خال را داری، ضعیف‌ترین کارت همان خال را بازی کن
          return weakestCard(sameSuitCards);
        }
      }
      // ۴. اگر هیچ کارتی از آن خال نداری
      if (sameSuitCards.isEmpty) {
        final hokmCards = hand.where((c) => c.suit == hokm).toList();
        if (hokmCards.isNotEmpty) {
          // نفر دوم: هیچ کارتی از آن خال نداری و حکم داری، ضعیف‌ترین حکم را بازی کن
          return weakestCard(hokmCards);
        } else {
          // نفر دوم: هیچ کارتی از آن خال و حکم نداری، ضعیف‌ترین کارت غیرحکم را بازی کن
          final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
          return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
        }
      }
    }
    // --- منطق نفر سوم (table.length == 2) ---
    else if (table.length == 2) {
      final firstCard = table[0];
      final secondCard = table[1];
      final leadSuit = firstCard.suit;
      final sameSuitCards = hand.where((c) => c.suit == leadSuit).toList();
      // اگر آس همان خال را داری و هنوز بازی نشده، آس را بازی کن
      final playedSuitRanks = tableHistory
          .expand((l) => l)
          .where((c) => c.suit == leadSuit)
          .map((c) => c.rank)
          .toList();
      if (sameSuitCards.any((c) => c.rank == Rank.ace) &&
          !playedSuitRanks.contains(Rank.ace)) {
        return sameSuitCards.firstWhere((c) => c.rank == Rank.ace);
      }
      // اگر کارت قوی‌تر همان خال را داری که می‌تواند برنده شود
      if (sameSuitCards.isNotEmpty) {
        final maxOnTable = strongestCard([firstCard, secondCard]);
        final winning = sameSuitCards
            .where((c) => c.rank.index < maxOnTable.rank.index)
            .toList();
        if (winning.isNotEmpty) {
          return weakestCard(winning);
        } else {
          return weakestCard(sameSuitCards);
        }
      }
      // اگر هیچ کارتی از آن خال نداری
      if (sameSuitCards.isEmpty) {
        final hokmCards = hand.where((c) => c.suit == hokm).toList();
        if (hokmCards.isNotEmpty) {
          return weakestCard(hokmCards);
        } else {
          final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
          return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
        }
      }
    }
    // --- منطق نفر چهارم (table.length == 3) ---
    else if (table.length == 3) {
      final firstCard = table[0];
      final secondCard = table[1];
      final thirdCard = table[2];
      final leadSuit = firstCard.suit;
      final sameSuitCards = hand.where((c) => c.suit == leadSuit).toList();
      // بررسی برنده فعلی روی میز
      final currentWinner = strongestCard([firstCard, secondCard, thirdCard]);
      // اگر کارت قوی‌تر داری که می‌تواند دست را ببرد
      if (sameSuitCards.isNotEmpty) {
        final winning = sameSuitCards
            .where((c) => c.rank.index < currentWinner.rank.index)
            .toList();
        if (winning.isNotEmpty) {
          return weakestCard(winning);
        } else {
          return weakestCard(sameSuitCards);
        }
      } else {
        // اگر کارت همان خال را نداری
        final hokmCards = hand.where((c) => c.suit == hokm).toList();
        if (hokmCards.isNotEmpty) {
          // آیا می‌توانی با حکم دست را ببری؟
          final tableHokms = [firstCard, secondCard, thirdCard]
              .where((c) => c.suit == hokm)
              .toList();
          final maxHokmOnTable =
              tableHokms.isNotEmpty ? strongestCard(tableHokms) : null;
          final winningHokms = maxHokmOnTable != null
              ? hokmCards
                  .where((c) => c.rank.index < maxHokmOnTable.rank.index)
                  .toList()
              : hokmCards;
          if (winningHokms.isNotEmpty) {
            return weakestCard(winningHokms);
          } else {
            return weakestCard(hokmCards);
          }
        } else {
          final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
          return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
        }
      }
    }
    // حالت پیش‌فرض:
    // print('بازی طبق حالت پیش‌فرض: ضعیف‌ترین کارت بازی می‌شود');
    final card = weakestCard(hand);
    hand.remove(card);
    return card;
  }

  List<GameCard> _suitCards(Suit suit) =>
      hand.where((c) => c.suit == suit).toList();
  List<GameCard> _sameSuitCards(GameCard card) => _suitCards(card.suit);

  GameCard _strongest(List<GameCard> cards) =>
      cards.reduce((a, b) => a.rank.index > b.rank.index ? a : b);
  GameCard _weakest(List<GameCard> cards) =>
      cards.reduce((a, b) => a.rank.index < b.rank.index ? a : b);

  List<GameCard> allPossibleCards() {
    return [
      for (final suit in Suit.values)
        for (final rank in Rank.values) GameCard(suit: suit, rank: rank)
    ];
  }
}

/// تیم (دو بازیکن)
class Team {
  final Player playerA;
  final Player playerB;
  int score = 0;
  Team(this.playerA, this.playerB);
}

/// کلاس اصلی منطق بازی حکم
class GameLogic {
  late List<GameCard> deck;
  late Direction hakem;
  late Direction tableDir;
  late Suit hokm;
  Direction directionHakemDetermination = Direction.bottom;
  List<List<GameCard>> hands = List.generate(4, (_) => []);
  List<Player> players = [];
  List<Team> teams = [];
  List<GameCard> table = [];
  List<List<GameCard>> tableHistory = [];
  int lastIndex = 52;

  GameLogic() {
    newGame();
  }

  void newGame() {
    for (var h in hands) {
      h.clear();
    }
    players.clear();
    teams.clear();
    table.clear();
    tableHistory.clear();
    deck = _getNewDeck();
    lastIndex = deck.length;
  }

  List<GameCard> _getNewDeck() {
    final cards = <GameCard>[];
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        cards.add(GameCard(suit: suit, rank: rank));
      }
    }
    cards.shuffle();
    return cards;
  }

//! تعیین حاکم
  void determineHakem() {
    var card = deck.last;
    directionHakemDetermination = Direction.bottom;
    while (card.rank != Rank.ace) {
      deck.removeLast();
      if (deck.isEmpty) break;
      card = deck.last;
      directionHakemDetermination =
          _getNextDirection(directionHakemDetermination);
    }
    hakem = directionHakemDetermination;
    tableDir = directionHakemDetermination;
    deck = _getNewDeck();
    lastIndex = deck.length;
  }

  Direction _getNextDirection(Direction direction) {
    switch (direction) {
      case Direction.bottom:
        return Direction.right;
      case Direction.right:
        return Direction.top;
      case Direction.top:
        return Direction.left;
      case Direction.left:
        return Direction.bottom;
    }
  }

//! توزیع کارت
  void dealCards(int numCards) {
    var dir = hakem;
    for (int i = 0; i < 4; i++) {
      final cardsToDeal =
          deck.getRange(lastIndex - numCards, lastIndex).toList();
      hands[dir.index].addAll(cardsToDeal);
      if (players.length == 4) {
        for (var card in cardsToDeal) {
          card.player = players[dir.index];
        }
      }
      lastIndex -= numCards;
      dir = _getNextDirection(dir);
    }
    // ساخت بازیکنان و تیم‌ها فقط در اولین تقسیم کارت
    if (numCards == 5 && players.isEmpty) {
      final aiLevel = Get.find<SettingsController>().aiLevel.value;
      players = [
        PlayerHuman('شما', hands[Direction.bottom.index], Direction.bottom),
        PlayerAI('حریف1', Direction.right, hands[Direction.right.index],
            aiLevel: aiLevel, isPartner: false),
        PlayerAI('یار شما', Direction.top, hands[Direction.top.index],
            aiLevel: aiLevel, isPartner: true),
        PlayerAI('حریف2', Direction.left, hands[Direction.left.index],
            aiLevel: aiLevel, isPartner: false),
      ];
      teams = [
        Team(players[0], players[2]),
        Team(players[1], players[3]),
      ];
      players[0].team = teams[0];
      players[2].team = teams[0];
      players[1].team = teams[1];
      players[3].team = teams[1];
      for (int idx = 0; idx < 4; idx++) {
        for (var card in hands[idx]) {
          card.player = players[idx];
        }
      }
    } else {
      for (int i = 0; i < 4; i++) {
        players[i].addHand(hands[i]);
        for (var card in hands[i]) {
          card.player = players[i];
        }
      }
    }
  }

//! اعتبارسنجی کارت
  bool isValidCard(GameCard card, Direction playerDir) {
    if (tableDir != Direction.bottom) return false;
    if (table.isEmpty) return true;
    final hasSameSuit = players[Direction.bottom.index]
        .hand
        .any((c) => c.suit == table[0].suit);
    if (!hasSameSuit) return true;
    if (table[0].suit == card.suit) return true;
    return false;
  }

//! بازی کردن کارت
  void playCard(GameCard card, Direction direction) {
    // حذف کارت از دست بازیکن (در منطق بازی)
    players[direction.index]
        .hand
        .removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    card.player = players[direction.index]; // اطمینان از مقداردهی درست
    table.add(card);
    tableDir = _getNextDirection(direction);
    if (table.length == 4) {
      final winner = getTableWinner(table, hokm, teams);
      winner.team.score++;
      tableDir = winner.direction;
      tableHistory.add(List.from(table));
      table.clear();
    }
  }

//! بازیکن برنده
  Player getTableWinner(List<GameCard> table, Suit hokm, List<Team> teams) {
    // اگر همه کارت‌ها هم‌خال باشند
    if (table.every((c) => c.suit == table[0].suit)) {
      return _getWinner(table);
    } else {
      // اگر حکم داری
      final hokmCards = table.where((c) => c.suit == hokm).toList();
      if (hokmCards.isNotEmpty) {
        return _getWinner(hokmCards);
      } else {
        // اگر حکم نداری
        final sameSuitAsFirst =
            table.where((c) => c.suit == table[0].suit).toList();
        return _getWinner(sameSuitAsFirst);
      }
    }
  }

//! بازیکن برنده
  Player _getWinner(List<GameCard> cards) {
    // کارت با بالاترین ارزش (index کمتر یعنی ارزش بیشتر)
    GameCard winnerCard = cards.first;
    for (var card in cards) {
      if (card.rank.index < winnerCard.rank.index) {
        winnerCard = card;
      }
    }
    return winnerCard.player!;
  }
}

/// بازیکن انسانی (برای تکمیل بعدی)
class PlayerHuman extends Player {
  PlayerHuman(super.name, super.cards, super.direction);

  @override
  GameCard play({
    required List<GameCard> table,
    required List<List<GameCard>> tableHistory,
    required List<Team> teams,
    required Suit hokm,
  }) {
    // منطق بازی بازیکن انسانی توسط UI کنترل می‌شود
    throw UnimplementedError('بازی بازیکن انسانی توسط UI انجام می‌شود');
  }
}
// -------------------- پایان منطق بازی حکم --------------------

/// کنترلر اصلی بازی حکم
///
/// این کلاس از [GetxController] ارث می‌برد و وضعیت بازی، منطق توزیع کارت، مدیریت نوبت‌ها،
/// بازی کردن کارت‌ها، امتیازدهی و تشخیص برنده را مدیریت می‌کند.
class GameController extends GetxController {
  /// لیست تمام کارت‌های بازی (۵۲ کارت).
  final cards = <GameCard>[].obs;

  /// اندیس کارت فعلی که در مرحله تعیین حاکم از روی پشته برداشته می‌شود.
  final currentCardIndex = 0.obs;

  /// وضعیت نمایش تاج و دایره زیر بازیکن حاکم در UI.
  final showTajAndCircle = false.obs;

  /// وضعیت نمایش کارت‌های دست بازیکنان در UI.
  final showCards = false.obs;

  /// وضعیت نمایش دکمه "شروع بازی" در UI.
  final showStartButton = true.obs;

  /// موقعیت‌های کارت‌ها برای انیمیشن توزیع کارت (در حال حاضر استفاده نمی‌شود).
  final cardPositions = {
    'left': 0.0.obs,
    'right': 0.0.obs,
    'top': 0.0.obs,
  }.obs;

  /// کارت های دست بازیکنان
  final playerCards = {
    'bottom': <GameCard>[].obs,
    'right': <GameCard>[].obs,
    'top': <GameCard>[].obs,
    'left': <GameCard>[].obs,
  }.obs;

  /// جهت بازیکنی که حاکم شده است (به صورت رشته).
  final hokmPlayer = ''.obs;

  /// وضعیت نشان‌دهنده در حال توزیع بودن کارت‌ها (در حال حاضر استفاده نمی‌شود).
  final isDistributing = false.obs;

  /// خال حکمی که توسط حاکم انتخاب شده است.
  final selectedHokm = Rxn<Suit>();

  /// وضعیت نمایش دیالوگ انتخاب حکم برای بازیکن انسانی.
  final showHokmDialog = false.obs;

  /// وضعیت نشان‌دهنده اتمام مرحله اول تقسیم کارت‌ها (۵ کارت).
  final isFirstDistributionDone = false.obs;

  /// وضعیت نشان‌دهنده اتمام مرحله دوم تقسیم کارت‌ها (۴ کارت).
  final isSecondDistributionDone = false.obs;

  /// وضعیت نشان‌دهنده اتمام مرحله سوم تقسیم کارت‌ها (۴ کارت).
  final isThirdDistributionDone = false.obs;

  /// جهت بازیکنی که نوبت بازی کردن اوست (به صورت رشته).
  final currentPlayer = ''.obs;

  /// نقشه‌ای که کارت‌های روی زمین را بر اساس جهت بازیکنی که آن را بازی کرده نگهداری می‌کند.
  final tableCards = <String, GameCard>{}.obs;

  /// وضعیت نشان‌دهنده اینکه آیا نوبت بازیکن پایین (انسانی) است.
  final isBottomPlayerTurn = false.obs;

  /// وضعیت نشان‌دهنده اینکه آیا بازی رسماً شروع شده است (بعد از انتخاب حکم).
  final isGameStarted = false.obs;

  /// امتیازات تیم‌ها.
  final teamScores = {
    'team1': 0.obs, // بازیکن پایین و بالا
    'team2': 0.obs, // بازیکن راست و چپ
  }.obs;

  /// خال اولین کارتی که در یک دست بازی شده است.
  final firstSuit = Rxn<Suit>();

  /// نمونه‌ای از کلاس GameLogic که حاوی منطق اصلی بازی است.
  late GameLogic game;

  BuildContext get context => Get.context!;

  /// متد اولیه ساز کنترلر که هنگام ایجاد شدن کنترلر فراخوانی می‌شود.
  /// در این متد نمونه GameLogic ساخته شده و کارت‌ها مقداردهی اولیه می‌شوند.
  @override
  void onInit() {
    super.onInit();
    game = GameLogic();
    _initializeCards();
  }

  /// مقداردهی اولیه کارت‌ها و وضعیت‌های مربوط به شروع بازی.
  /// لیست کارت‌ها را پاک کرده، وضعیت‌های UI را بازنشانی کرده و یک دست کارت جدید ایجاد و توزیع می‌کند.
  void _initializeCards() {
    cards.clear();
    for (var list in playerCards.values) {
      list.clear();
    }
    hokmPlayer.value = '';
    showCards.value = false;
    showStartButton.value = true;
    showTajAndCircle.value = false;
    selectedHokm.value = null;
    showHokmDialog.value = false;
    isFirstDistributionDone.value = false;
    isSecondDistributionDone.value = false;
    isThirdDistributionDone.value = false;
    cardPositions['left']?.value = 0.0;
    cardPositions['right']?.value = 0.0;
    cardPositions['top']?.value = 0.0;
    // راه‌حل جدید: فقط یک بار deck را بساز و shuffle کن و به هر دو لیست مقدار بده
    final newDeck = game._getNewDeck();
    newDeck.shuffle(Random());
    cards.addAll(newDeck);
    game.deck = List.from(newDeck);
  }

  /// شروع فرآیند بازی.
  /// دکمه شروع را مخفی کرده، کارت‌ها را نمایش داده و فرآیند توزیع کارت برای تعیین حاکم را آغاز می‌کند.
  void startGame() async {
    snackMessage(title: 'انتخاب حاکم');
    showStartButton.value = false;
    showCards.value = true;
    isGameStarted.value = false;
    await _distributeCardsForHakem();
  }

  /// پخش مرحله‌ای کارت‌ها برای تعیین حاکم.
  /// کارت‌ها را به صورت تک‌تک بین بازیکنان توزیع می‌کند تا آس برای تعیین حاکم پیدا شود.
  /// پس از پیدا شدن حاکم، کارت‌ها جمع‌آوری شده و فرآیند توزیع اصلی آغاز می‌شود.
  Future<void> _distributeCardsForHakem() async {
    // راه‌حل جدید: فقط یک بار deck را بساز و shuffle کن و به هر دو لیست مقدار بده
    final newDeck = game._getNewDeck();
    newDeck.shuffle(Random());
    cards.clear();
    cards.addAll(newDeck);
    game.deck = List.from(newDeck);
    for (var list in playerCards.values) {
      list.clear();
    }
    hokmPlayer.value = '';
    showTajAndCircle.value = false;
    selectedHokm.value = null;
    showHokmDialog.value = false;
    isFirstDistributionDone.value = false;
    isSecondDistributionDone.value = false;
    isThirdDistributionDone.value = false;
    cardPositions['left']?.value = 0.0;
    cardPositions['right']?.value = 0.0;
    cardPositions['top']?.value = 0.0;
    int currentCardIndex = 0;
    final distributionOrder = ['bottom', 'right', 'top', 'left'];
    int currentPlayerIndex = 0;
    bool hakemFound = false;
    while (currentCardIndex < cards.length) {
      final currentCard = cards[currentCardIndex];
      final currentPlayer = distributionOrder[currentPlayerIndex];
      playerCards[currentPlayer]?.add(currentCard);
      cards.removeAt(currentCardIndex); // حذف کارت از پشته وسط
      update();
      await Future.delayed(const Duration(milliseconds: 350));
      if (currentCard.rank == Rank.ace) {
        hokmPlayer.value = currentPlayer;
        showTajAndCircle.value = true;
        Get.snackbar(
          'حاکم مشخص شد!',
          '${getPlayerName(currentPlayer)} حاکم شد',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        hakemFound = true;
        break;
      }
      // currentCardIndex++ حذف شد چون removeAt انجام می‌شود
      currentPlayerIndex = (currentPlayerIndex + 1) % 4;
    }
    if (hakemFound) {
      await Future.delayed(const Duration(seconds: 2));
      // جمع‌آوری کارت‌ها و توزیع مجدد
      for (var list in playerCards.values) {
        list.clear();
      }
      // راه‌حل جدید: فقط یک بار deck را بساز و shuffle کن و به هر دو لیست مقدار بده
      final newDeck = game._getNewDeck();
      newDeck.shuffle(Random());
      cards.clear();
      cards.addAll(newDeck);
      game.deck = List.from(newDeck);
      cardPositions.value = {
        'left': (-50.0).obs,
        'right': (-50.0).obs,
        'top': (-60.0).obs,
      };

      // مقداردهی اولیه دست‌ها و بازیکنان
      game.hakem = _stringToDirection(hokmPlayer.value);
      // مرحله اول: ۵ کارت به هر بازیکن، تک‌تک
      await _dealCardsStepByStep(5);
      // مقداردهی بازیکنان و تیم‌ها بعد از توزیع ۵ کارت
      if (game.players.isEmpty) {
        final aiLevel = Get.find<SettingsController>().aiLevel.value;
        game.players = [
          PlayerHuman(
              'شما', game.hands[Direction.bottom.index], Direction.bottom),
          PlayerAI('حریف1', Direction.right, game.hands[Direction.right.index],
              aiLevel: aiLevel, isPartner: false),
          PlayerAI('یار شما', Direction.top, game.hands[Direction.top.index],
              aiLevel: aiLevel, isPartner: true),
          PlayerAI('حریف2', Direction.left, game.hands[Direction.left.index],
              aiLevel: aiLevel, isPartner: false),
        ];
        game.teams = [
          Team(game.players[0], game.players[2]),
          Team(game.players[1], game.players[3]),
        ];
        game.players[0].team = game.teams[0];
        game.players[2].team = game.teams[0];
        game.players[1].team = game.teams[1];
        game.players[3].team = game.teams[1];
      }
      // نمایش دیالوگ انتخاب حکم اگر حاکم human باشد
      if (game.hakem == Direction.bottom) {
        showHokmDialog.value = true;
      } else {
        final aiHokm = game.players[game.hakem.index].determineHokm();
        selectHokm(aiHokm);
      }
    }
  }

  /// همگام‌سازی کارت‌های دست بازیکنان بین منطق UI (playerCards) و منطق بازی (game.hands).
  /// این متد تضمین می‌کند که UI همیشه بازتاب‌دهنده وضعیت صحیح دست بازیکنان در منطق بازی است.
  void _syncHandsWithUI() {
    for (var pos in ['bottom', 'right', 'top', 'left']) {
      playerCards[pos]?.clear();
    }
    for (int i = 0; i < 4; i++) {
      final dir = Direction.values[i];
      final pos = _directionToString(dir);
      playerCards[pos]?.addAll(game.hands[i]);
      // دست بازیکن را با game.hands[i] sync کن
      if (game.players.length == 4) {
        game.players[i].hand.clear();
        game.players[i].hand.addAll(game.hands[i]);
      }
    }
    // مرتب‌سازی کارت‌های بازیکن پایین بعد از هر sync
    _sortBottomPlayerCards();
    // هیچ تغییری در cardPositions یا پوزیشن کارت‌ها داده نمی‌شود
  }

  /// تعیین ترتیب توزیع کارت‌ها بر اساس حاکم.
  /// حاکم اولین نفر برای دریافت کارت است و پس از او به ترتیب بقیه بازیکنان.
  ///
  /// Args:
  ///   start: جهت حاکم که نقطه شروع توزیع است.
  ///
  /// Returns:
  ///   لیستی از جهت‌ها به ترتیب توزیع کارت.
  List<Direction> _getDistributionOrder(Direction start) {
    return List.generate(4, (i) => Direction.values[(start.index + i) % 4]);
  }

  /// توزیع کارت به صورت تک‌تک برای هر بازیکن در مراحل مختلف بازی (۵ یا ۴ کارت).
  /// کارت‌ها را از پشته برداشته و به دست بازیکنان و یو آی اضافه می‌کند.
  ///
  /// Args:
  ///   numCards: تعداد کارت‌هایی که در این مرحله به هر بازیکن داده می‌شود.
  Future<void> _dealCardsStepByStep(int numCards) async {
    final order = _getDistributionOrder(game.hakem);
    for (final dir in order) {
      for (int i = 0; i < numCards; i++) {
        // کارت را از ابتدای deck بردار و به دست بازیکن و UI اضافه کن
        final card = game.deck.removeAt(0);
        game.hands[dir.index].add(card);
        card.player = game.players.isNotEmpty ? game.players[dir.index] : null;
        playerCards[_directionToString(dir)]?.add(card);
        cards.removeAt(0); // کارت بالایی را از پشته وسط هم حذف کن
        update();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    // بعد از هر مرحله sync کامل
    _syncHandsWithUI();
  }

  /// تبدیل رشته موقعیت (مانند 'bottom') به enum Direction.
  ///
  /// Args:
  ///   pos: رشته موقعیت بازیکن.
  ///
  /// Returns:
  ///   enum Direction مربوط به رشته موقعیت.
  Direction _stringToDirection(String pos) {
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

  /// تبدیل enum Direction به رشته موقعیت برای استفاده در UI.
  ///
  /// Args:
  ///   dir: enum Direction بازیکن.
  ///
  /// Returns:
  ///   رشته موقعیت (String) مربوط به Direction.
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

  /// انتخاب خال حکم توسط بازیکن حاکم (چه انسانی و چه AI).
  /// پس از انتخاب حکم، مراحل بعدی توزیع کارت انجام شده و بازی رسماً آغاز می‌شود.
  ///
  /// Args:
  ///   suit: خال حکمی که انتخاب شده است.
  void selectHokm(Suit suit) async {
    selectedHokm.value = suit;
    showHokmDialog.value = false;
    isGameStarted.value = true;
    game.hokm = suit;
    // مرحله دوم: ۴ کارت به هر بازیکن، تک‌تک
    await _dealCardsStepByStep(4);
    await Future.delayed(const Duration(milliseconds: 300));
    // مرحله سوم: ۴ کارت به هر بازیکن، تک‌تک
    await _dealCardsStepByStep(4);
    // مرتب‌سازی کارت‌های بازیکن پایین بعد از تکمیل دست
    _sortBottomPlayerCards();
    // نوبت را به حاکم بده
    currentPlayer.value = hokmPlayer.value;
    isBottomPlayerTurn.value = hokmPlayer.value == 'bottom';
    // اگر حاکم AI بود، کارت بازی کند
    if (game.hakem != Direction.bottom) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _playComputerCard();
      });
    }
  }

  /// مرتب‌سازی کارت‌های بازیکن پایین (انسانی) بر اساس خال و سپس ارزش.
  /// این کار برای نمایش منظم کارت‌ها در دست بازیکن پایین انجام می‌شود.
  void _sortBottomPlayerCards() {
    if (playerCards['bottom']?.isNotEmpty ?? false) {
      playerCards['bottom']?.sort((a, b) {
        // suit: Hearts (0), Clubs (1), Diamonds (2), Spades (3)
        final suitOrder = {
          Suit.hearts: 0,
          Suit.clubs: 1,
          Suit.diamonds: 2,
          Suit.spades: 3,
        };
        if (a.suit != b.suit) {
          return suitOrder[a.suit]!.compareTo(suitOrder[b.suit]!);
        }
        return a.rank.index.compareTo(b.rank.index); // صعودی (آس تا ۲)
      });
    }
  }

  /// پردازش بازی کردن یک کارت توسط بازیکن.
  /// ابتدا اعتبار کارت بررسی می‌شود، سپس کارت از دست بازیکن حذف شده و به کارت‌های روی میز اضافه می‌شود.
  /// پس از هر دست، برنده مشخص شده و نوبت به بازیکن بعدی داده می‌شود.
  ///
  /// Args:
  ///   card: کارتی که بازیکن قصد بازی کردن آن را دارد.
  void playCard(GameCard card) {
    if (!canPlayCard(card)) return;
    final dir = Direction.values
        .firstWhere((d) => _directionToString(d) == currentPlayer.value);
    // حذف کارت از دست بازیکن در UI (قبل از sync)
    playerCards[currentPlayer.value]
        ?.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    // حذف کارت از دست بازیکن در منطق بازی (قبل از sync)
    game.hands[dir.index]
        .removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    if (game.players.length == 4) {
      game.players[dir.index].hand
          .removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    }
    // بازی کارت با منطق جدید
    game.playCard(card, dir);
    // sync دست بازیکنان با UI (بعد از حذف)
    _syncHandsWithUI();
    // کارت را به tableCards UI اضافه کن
    tableCards[currentPlayer.value] = card;
    if (game.table.length == 1) {
      firstSuit.value = card.suit;
    }
    if (game.table.isEmpty) {
      final winner = _directionToString(game.tableDir);
      _endHandUI(winner);
    } else {
      currentPlayer.value = _directionToString(game.tableDir);
      isBottomPlayerTurn.value = currentPlayer.value == 'bottom';
      if (currentPlayer.value != 'bottom') {
        Future.delayed(const Duration(milliseconds: 1000), () {
          _playComputerCard();
        });
      }
    }
  }

  /// اجرای نوبت بازی برای بازیکنان هوش مصنوعی.
  /// بر اساس سطح هوشمندی AI، کارت مناسب انتخاب شده و توسط متد `playCard` بازی می‌شود.
  void _playComputerCard() {
    if (currentPlayer.value == 'bottom') return;
    final dir = Direction.values
        .firstWhere((d) => _directionToString(d) == currentPlayer.value);
    final ai = game.players[dir.index];
    final card = ai.play(
      table: List.from(game.table),
      tableHistory: List.from(game.tableHistory),
      teams: List.from(game.teams),
      hokm: game.hokm,
    );
    playCard(card);
  }

  /// مدیریت پایان یک دست بازی.
  /// برنده دست مشخص شده، امتیاز تیم برنده افزایش یافته، کارت‌های روی میز پاک شده و نوبت به برنده دست داده می‌شود.
  /// در صورت رسیدن امتیاز تیمی به ۷، بازی پایان می‌یابد.
  ///
  /// Args:
  ///   winner: جهت بازیکنی که برنده دست شده است (به صورت رشته).
  Future<void> _endHandUI(String winner) async {
    // امتیازدهی
    if (winner == 'bottom' || winner == 'top') {
      teamScores['team1']?.value++;
    } else {
      teamScores['team2']?.value++;
    }
    // بررسی برنده بازی
    if (teamScores['team1']?.value == 7 || teamScores['team2']?.value == 7) {
      await Future.delayed(
          const Duration(seconds: 1)); // تاخیر برای نمایش کارت آخر
      _endGame();
      return;
    }
    // تاخیر برای نمایش کارت‌ها
    await Future.delayed(const Duration(seconds: 2));
    // پاک کردن کارت‌های روی میز
    tableCards.clear();
    firstSuit.value = null;
    // شروع دست جدید با بازیکن برنده
    currentPlayer.value = winner;
    isBottomPlayerTurn.value = winner == 'bottom';
    // اگر برنده AI بود، کارت بازی کند
    if (winner != 'bottom') {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _playComputerCard();
      });
    }
  }

  /// مدیریت پایان بازی.
  /// تیم برنده را مشخص کرده و یک دیالوگ برای اعلام پایان بازی و برنده نمایش می‌دهد.
  void _endGame() {
    final winningTeam = teamScores['team1']?.value == 7 ? 'team1' : 'team2';
    final winningTeamName = winningTeam == 'team1' ? 'شما ' : 'حریف ';

    Get.dialog(
      AlertDialog(
        title: Text('پایان بازی'),
        content: Text('$winningTeamName برنده شدند!'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // برگشت به صفحه قبل
            },
            child: Text('بستن'),
          ),
        ],
      ),
    );
  }

  /// بررسی اینکه آیا بازیکن پایین می‌تواند کارت انتخاب شده را بازی کند.
  /// قوانین بازی حکم (مثلاً همراهی کردن با خال اول دست) را بررسی می‌کند.
  ///
  /// Args:
  ///   card: کارتی که بازیکن پایین قصد بازی کردن آن را دارد.
  ///
  /// Returns:
  ///   `true` اگر کارت قابل بازی باشد، `false` در غیر این صورت.
  bool canPlayCard(GameCard card) {
    // اگر نوبت بازیکن پایین نیست و بازیکن پایین نیست، اجازه بازی بده
    if (!isBottomPlayerTurn.value && currentPlayer.value != 'bottom') {
      return true;
    }

    // اگر نوبت بازیکن پایین نیست، اجازه بازی نده
    if (!isBottomPlayerTurn.value) {
      snackMessage(title: 'نوبت شما نیست');
      return false;
    }
    // اگر جدول خالی است، اجازه بازی بده
    if (tableCards.isEmpty) {
      return true;
    }

    // اگر کارت از خال اول دست نباشد و بازیکن کارت از خال اول دست داشته باشد، نمی‌تواند کارت دیگری بازی کند
    if (card.suit != firstSuit.value) {
      final hasFirstSuitCard =
          playerCards['bottom']!.any((c) => c.suit == firstSuit.value);
      if (hasFirstSuitCard) {
        snackMessage(title: 'کارت  نامعتبر !!!');

        return false;
      }
    }
    return true;
  }

  void snackMessage({required String title}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 500),
        width: 150,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 10,
        content: Text(
          textAlign: TextAlign.center,
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// حذف کارت بالای پشته کارت‌ها (در مرحله تعیین حاکم استفاده می‌شود).
  void removeTopCard() {
    if (currentCardIndex.value < cards.length) {
      currentCardIndex.value++;
    }
  }

  /// گرفتن نام فارسی بازیکن بر اساس موقعیت.
  ///
  /// Args:
  ///   position: موقعیت بازیکن (bottom, right, top, left).
  ///
  /// Returns:
  ///   نام فارسی بازیکن (String).
  String getPlayerName(String position) {
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
}

/// کلاس اصلی صفحه بازی حکم
/// این کلاس واسط کاربری بازی را نمایش می‌دهد و با GameController برای مدیریت منطق بازی تعامل دارد.
class GameScreen extends StatelessWidget {
  /// کنترلر اصلی بازی که منطق و وضعیت بازی را مدیریت می‌کند.
  final controller = Get.put(GameController());

  /// کنترلر تنظیمات برای دسترسی به تنظیمات پس‌زمینه و غیره.
  final settingsController = Get.put(SettingsController());

  /// سازنده کلاس GameScreen.
  GameScreen({super.key});

  /// متد اصلی ساخت واسط کاربری صفحه بازی.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, PopupRoute? route) async {
        if (!didPop) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('خروج از بازی'),
              content: Text('آیا می‌خواهید از بازی خارج شوید؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('خیر'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('بله'),
                ),
              ],
            ),
          );

          if (shouldPop == true) {
            Get.back();
          }
        }
      },
      child: Obx(() {
        final idx = settingsController.backgroundIndex.value;
        final isColor = idx < settingsController.backgroundColors.length;
        return Scaffold(
          body: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              isColor
                  ? Container(color: settingsController.backgroundColors[idx])
                  : Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(settingsController.backgroundImages[
                              idx -
                                  settingsController.backgroundColors.length]),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
              textTop(),
              cardCenter(),
              Obx(() => controller.showCards.value ? cardBotton() : SizedBox()),
              Obx(() => controller.showCards.value ? cardLeft() : SizedBox()),
              Obx(() => controller.showCards.value ? cardRight() : SizedBox()),
              Obx(() => controller.showCards.value ? cardTop() : SizedBox()),
              Positioned(
                right: 4,
                top: 4,
                child: CircleAvatar(
                  child: CloseButton(),
                ),
              ),
              Obx(() => controller.showHokmDialog.value &&
                      controller.hokmPlayer.value == 'bottom'
                  ? _buildHokmSelectionDialog()
                  : SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  /// نمایش اطلاعات بالای صفحه شامل امتیازات و خال حکم انتخاب شده.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی اطلاعات بالای صفحه.
  Widget textTop() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          bkgText(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() => Text(
                    'شما و یار: ${controller.teamScores['team1']?.value}')),
                Obx(() =>
                    Text('حریفان: ${controller.teamScores['team2']?.value}')),
              ],
            ),
          ),
          Obx(() => controller.selectedHokm.value != null
              ? bkgText(
                  child: Column(
                    children: [
                      Text(
                        'حکم ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Image.asset(
                        'assets/drawables/${_getSuitImageName(controller.selectedHokm.value!)}',
                        width: 20,
                      ),
                    ],
                  ),
                )
              : SizedBox()),
        ],
      ),
    );
  }

  /// ساختار پس‌زمینه متنی برای نمایش امتیازات و حکم.
  /// یک Container با استایل خاص (پس‌زمینه خاکستری و گوشه‌های گرد) ایجاد می‌کند.
  ///
  /// Args:
  ///   child: ویجت فرزند که درون Container قرار می‌گیرد (مانند متن امتیازات).
  ///
  /// Returns:
  ///   ویجت Container با استایل پس‌زمینه.
  Container bkgText({required Widget child}) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child);
  }

  /// نمایش پشته کارت‌ها در مرکز صفحه (قبل از شروع بازی) یا کارت‌های روی میز (هنگام بازی).
  /// وضعیت‌های مختلف (نمایش دکمه شروع، نمایش پشته کارت یا کارت‌های روی میز) را مدیریت می‌کند.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی Stack برای نمایش کارت‌های مرکز.
  Widget cardCenter() {
    return Positioned(
      bottom: 0,
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(
          () => controller.showStartButton.value
              ? ElevatedButton(
                  onPressed: controller.startGame,
                  child: Text('انتخاب حاکم'),
                )
              : SizedBox(
                  height: 150,
                  width: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // نمایش کارت‌های روی میز در حالت بازی
                      Obx(() => controller.isGameStarted.value &&
                              controller.tableCards.isNotEmpty
                          ? Positioned(
                              child: Stack(
                                children: [
                                  for (var entry
                                      in controller.tableCards.entries)
                                    Align(
                                      alignment: entry.key == 'left'
                                          ? Alignment.centerLeft
                                          : entry.key == 'right'
                                              ? Alignment.centerRight
                                              : entry.key == 'top'
                                                  ? Alignment.topCenter
                                                  : Alignment.bottomCenter,
                                      child: CardWidget(
                                        card: entry.value,
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : SizedBox()),
                      // نمایش کارت‌های پشته فقط زمانی که بازی شروع نشده یا در مرحله تعیین حاکم هستیم
                      if (controller.showCards.value &&
                          controller.cards.isNotEmpty)
                        for (int i = controller.cards.length - 1; i >= 0; i--)
                          Positioned(
                            child: CardWidget(
                              card: controller.cards[i],
                            ),
                          ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// نمایش کارت‌های بازیکن پایین (بازیکن انسانی).
  /// موقعیت کارت‌ها را در پایین صفحه مدیریت می‌کند و امکان تعامل با کارت‌ها (انتخاب برای بازی) را فراهم می‌سازد.
  /// همچنین تاج حاکم را در صورت لزوم نمایش می‌دهد.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی کارت‌های بازیکن پایین.
  Widget cardBotton() {
    return Builder(
        builder: (context) => Obx(
              () => Positioned(
                bottom: controller.cardPositions['bottom']?.value ?? 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    if (controller.hokmPlayer.value == 'bottom') ...tajAnCir(),
                    SizedBox(height: 6),
                    Center(
                      child: Obx(
                        () => controller.playerCards['bottom']?.isNotEmpty ??
                                false
                            ? SizedBox(
                                height: 88,
                                width:
                                    controller.playerCards['bottom']!.length *
                                            (MediaQuery.of(context).size.width *
                                                0.0526) +
                                        30,
                                // width: MediaQuery.of(context).size.width * 0.7,
                                child: Stack(
                                    // alignment: Alignment.center,
                                    children: [
                                      for (int i = 0;
                                          i <
                                              controller.playerCards['bottom']!
                                                  .length;
                                          i++)
                                        Positioned(
                                          // right: 1,

                                          left: i *
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.0526),
                                          child: GestureDetector(
                                            onTap: () {
                                              final card = controller
                                                  .playerCards['bottom']![i];

                                              if (controller.isBottomPlayerTurn
                                                      .value &&
                                                  controller
                                                      .canPlayCard(card)) {
                                                controller.playCard(card);
                                              }
                                            },
                                            child: CardWidget(
                                              card: controller
                                                  .playerCards['bottom']![i],
                                              isSelectable: controller
                                                  .isBottomPlayerTurn.value,
                                            ),
                                          ),
                                        ),
                                    ]))
                            : SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  /// نمایش کارت‌های بازیکن چپ (هوش مصنوعی حریف).
  /// کارت‌ها را در سمت چپ صفحه به صورت عمودی نمایش می‌دهد و تاج حاکم را در صورت لزوم نمایش می‌دهد.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی کارت‌های بازیکن چپ.
  Widget cardLeft() {
    return Builder(
        builder: (context) => Obx(() => Positioned(
            left: (controller.cardPositions['left']?.value ?? 50) + 50,
            bottom: 0,
            top: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(controller.getPlayerName('left')),
                    if (controller.hokmPlayer.value == 'left') ...tajAnCir(),
                  ],
                ),
                SizedBox(width: 6),
                Center(
                  child: Obx(
                    () => controller.playerCards['left']?.isNotEmpty ?? false
                        ? SizedBox(
                            height: 330,
                            width: 65,
                            child: Stack(
                              children: [
                                for (int i = 0;
                                    i < controller.playerCards['left']!.length;
                                    i++)
                                  Positioned(
                                    top: i *
                                        (MediaQuery.of(context).size.height *
                                            0.14 *
                                            0.4),
                                    child: CardWidget(
                                      card: controller.playerCards['left']![i],
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : SizedBox(),
                  ),
                ),
              ],
            ))));
  }

  /// نمایش کارت‌های بازیکن راست (هوش مصنوعی حریف).
  /// کارت‌ها را در سمت راست صفحه به صورت عمودی نمایش می‌دهد و تاج حاکم را در صورت لزوم نمایش می‌دهد.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی کارت‌های بازیکن راست.
  Widget cardRight() {
    return Builder(
      builder: (context) => Obx(
        () => Positioned(
          right: (controller.cardPositions['right']?.value ?? 50) + 50,
          bottom: 0,
          top: 0,
          child: Row(
            children: [
              Center(
                child: Obx(
                  () => controller.playerCards['right']?.isNotEmpty ?? false
                      ? SizedBox(
                          height: 330,
                          width: 65,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              for (int i = 0;
                                  i < controller.playerCards['right']!.length;
                                  i++)
                                Positioned(
                                  top: i *
                                      (MediaQuery.of(context).size.height *
                                          0.14 *
                                          0.4),
                                  child: CardWidget(
                                    card: controller.playerCards['right']![i],
                                  ),
                                ),
                            ],
                          ),
                        )
                      : SizedBox(),
                ),
              ),
              SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(controller.getPlayerName('right')),
                  if (controller.hokmPlayer.value == 'right') ...tajAnCir()
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// نمایش کارت‌های بازیکن بالا (هوش مصنوعی یار).
  /// کارت‌ها را در بالای صفحه به صورت افقی نمایش می‌دهد و تاج حاکم را در صورت لزوم نمایش می‌دهد.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی کارت‌های بازیکن بالا.
  Widget cardTop() {
    return Builder(
        builder: (context) => Obx(
              () => Positioned(
                top: (controller.cardPositions['top']?.value ?? 1),
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Center(
                      child: Obx(
                        () => controller.playerCards['top']?.isNotEmpty ?? false
                            ? SizedBox(
                                height: 88,
                                width: 250,
                                child: Stack(children: [
                                  for (int i = 0;
                                      i < controller.playerCards['top']!.length;
                                      i++)
                                    Positioned(
                                      right: i *
                                          (MediaQuery.of(context).size.width *
                                              0.19 *
                                              0.09),
                                      child: CardWidget(
                                        card: controller.playerCards['top']![i],
                                      ),
                                    ),
                                ]))
                            : SizedBox(),
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.getPlayerName('top')),
                        if (controller.hokmPlayer.value == 'top') ...tajAnCir()
                      ],
                    ),
                  ],
                ),
              ),
            ));
  }

  /// ویجت‌های نمایش دهنده تاج حاکم.
  ///
  /// Returns:
  ///   لیستی از ویجت‌ها (شامل عکس تاج).
  List<Widget> tajAnCir() {
    return [
      Image.asset(
        'assets/drawables/taj.png',
        height: 20,
      ),
    ];
  }

  /// ساخت دیالوگ انتخاب خال حکم برای بازیکن انسانی.
  /// زمانی نمایش داده می‌شود که حاکم بازیکن پایین باشد و نیاز به انتخاب حکم باشد.
  ///
  /// Returns:
  ///   ویجت Container حاوی دیالوگ انتخاب حکم.
  Widget _buildHokmSelectionDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'انتخاب خال حکم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSuitButton(Suit.hearts, 'hearts.png'),
                  _buildSuitButton(Suit.clubs, 'clubs.png'),
                  _buildSuitButton(Suit.diamonds, 'diamonds.png'),
                  _buildSuitButton(Suit.spades, 'spades.png'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ساخت دکمه انتخاب یک خال خاص در دیالوگ انتخاب حکم.
  ///
  /// Args:
  ///   suit: خال مربوط به دکمه (Hearts, Clubs, Diamonds, Spades).
  ///   imageName: نام فایل عکس مربوط به خال.
  ///
  /// Returns:
  ///   ویجت InkWell حاوی دکمه انتخاب خال.
  Widget _buildSuitButton(Suit suit, String imageName) {
    return InkWell(
      onTap: () => controller.selectHokm(suit),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          'assets/drawables/$imageName',
          width: 40,
          height: 40,
        ),
      ),
    );
  }

  /// گرفتن نام فایل عکس مربوط به یک خال.
  ///
  /// Args:
  ///   suit: خال مورد نظر.
  ///
  /// Returns:
  ///   نام فایل عکس (String) مربوط به خال.
  String _getSuitImageName(Suit suit) {
    switch (suit) {
      case Suit.hearts:
        return 'hearts.png';
      case Suit.clubs:
        return 'clubs.png';
      case Suit.diamonds:
        return 'diamonds.png';
      case Suit.spades:
        return 'spades.png';
    }
  }
}

// -------------------- توابع کمکی هوش مصنوعی پیشرفته --------------------

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

/// پیدا کردن قوی‌ترین کارت از یک لیست کارت
GameCard strongestCard(List<GameCard> cards) {
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
    final winningCard = strongestCard(hand);
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

// -------------------- پایان توابع کمکی هوش مصنوعی --------------------
