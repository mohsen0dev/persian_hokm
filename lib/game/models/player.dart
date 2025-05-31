import 'package:persian_hokm/game/enums.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/models/team.dart'; // Will be created next
import 'package:persian_hokm/game/core/ai_logic.dart'; // Will be created soon

// -------------------- منطق بازی حکم (تبدیل شده از کاتلین) --------------------

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
