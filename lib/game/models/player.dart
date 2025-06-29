import 'package:persian_hokm/game/models/enums.dart';
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

  /// آخرین خالی که یار بازی کرده (برای استراتژی هوشمند)
  Suit? lastPartnerSuit;

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
    //! جهت شروع‌کننده دست
    required Direction starterDirection,
  });

  /// به‌روزرسانی آخرین خال بازی‌شده توسط یار
  void updateLastPartnerSuit(Suit suit) {
    lastPartnerSuit = suit;
  }

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
    required Direction starterDirection,
  }) {
    //! سطح هوش مصنوعی موثر
    final effectiveLevel = isPartner ? 2 : aiLevel;
    switch (effectiveLevel) {
      case 0:
        return _basicPlay(table, hokm);
      case 1:
        return _intermediatePlay(table, hokm);
      case 2:
        return _advancedPlay(table, hokm, tableHistory, teams,
            starterDirection: starterDirection);
      default:
        return _advancedPlay(table, hokm, tableHistory, teams,
            starterDirection: starterDirection);
    }
  }

  GameCard _basicPlay(List<GameCard> table, Suit hokm) {
    //! اگر جدول خالی است
    if (table.isEmpty) {
      //! کارت‌های غیر حکم
      final nonHokms = hand.where((c) => c.suit != hokm).toList();
      return nonHokms.isNotEmpty
          ? strongestCard(nonHokms)
          : strongestCard(hand);
    }

    //! کارت‌های هم خال
    final sameSuit = _sameSuitCards(table.first);
    if (sameSuit.isNotEmpty) {
      return weakestCard(sameSuit);
    }

    //! کارت‌های حکم
    final hokms = _suitCards(hokm);
    return hokms.isNotEmpty ? weakestCard(hokms) : weakestCard(hand);
  }

  GameCard _intermediatePlay(List<GameCard> table, Suit hokm) {
    //! اگر جدول خالی است
    if (table.isEmpty) return strongestCard(hand);

    //! کارت‌های هم خال
    final sameSuit = _sameSuitCards(table.first);
    if (sameSuit.isNotEmpty) {
      final maxOnTable = strongestCard(
          table.where((c) => c.suit == table.first.suit).toList());
      final winning =
          sameSuit.where((c) => c.rank.index < maxOnTable.rank.index).toList();
      return winning.isNotEmpty ? weakestCard(winning) : weakestCard(sameSuit);
    }

    final hokms = _suitCards(hokm);
    return hokms.isNotEmpty ? strongestCard(hokms) : weakestCard(hand);
  }

  GameCard _advancedPlay(List<GameCard> table, Suit hokm,
      List<List<GameCard>> tableHistory, List<Team> teams,
      {required Direction starterDirection}) {
    // اگر نفر اول هستیم (table خالی است)
    if (table.isEmpty) {
      // دست اول (۱۳ کارت)
      return firstCard(hokm, tableHistory, table, teams, starterDirection);
    } // --- منطق نفر دوم (table.length == 1) ---
    else if (table.length == 1) {
      return secondCard(hokm, tableHistory, table, teams);
    }
    // --- منطق نفر سوم (table.length == 2) ---
    else if (table.length == 2) {
      return thirdCard(hokm, tableHistory, table, teams);
    }
    // --- منطق نفر چهارم (table.length == 3) ---
    else if (table.length == 3) {
      return fourthCard(hokm, tableHistory, table, teams);
    }
    // حالت پیش‌فرض:
    print('[$name][$direction] (پیش‌فرض): ضعیف‌ترین کارت بازی می‌شود');
    final card = weakestCard(hand);
    hand.remove(card);
    return card;
  }

//! هوش مصنوعی نفر اول
  GameCard firstCard(Suit hokm, List<List<GameCard>> tableHistory,
      List<GameCard> table, List<Team> teams, Direction starterDirection) {
    // اگر یار در دست قبلی یک خال خاص بازی کرده و کارت از آن خال داری، ضعیف‌ترین کارت همان خال را بازی کن
    if (lastPartnerSuit != null) {
      final mySuitCards = hand.where((c) => c.suit == lastPartnerSuit).toList();
      if (mySuitCards.isNotEmpty) {
        print(
            '[$name][$direction] (اولویت ویژه): چون یار آخرین بار این خال را بازی کرده، ضعیف‌ترین کارت همان خال بازی می‌شود');
        return weakestCard(mySuitCards);
      }
    }
    // دست اول (۱۳ کارت)
    if (hand.length == 13) {
      // اولویت ۱: آس غیر حکم
      final nonHokmAces =
          hand.where((c) => c.suit != hokm && c.rank == Rank.ace).toList();
      if (nonHokmAces.isNotEmpty) {
        print(
            '[$name][$direction] (اولین نفر/دست اول): بازی طبق اولویت ۱: آس غیر حکم');
        return nonHokmAces.first;
      }
      // اولویت ۲: شاه غیر حکم
      final nonHokmKings =
          hand.where((c) => c.suit != hokm && c.rank == Rank.king).toList();
      if (nonHokmKings.isNotEmpty) {
        print(
            '[$name][$direction] (اولین نفر/دست اول): بازی طبق اولویت ۲: شاه غیر حکم');
        final king = nonHokmKings.first;
        final sameSuitCards = hand.where((c) => c.suit == king.suit).toList();
        return weakestCard(sameSuitCards);
      }
      // اولویت ۳: خال غیر حکم با ۳ یا کمتر کارت
      final nonHokmSuits = Suit.values.where((s) => s != hokm);
      for (final suit in nonHokmSuits) {
        final suitCards = hand.where((c) => c.suit == suit).toList();
        if (suitCards.length <= 3 && suitCards.isNotEmpty) {
          print(
              '[$name][$direction] (اولین نفر/دست اول): بازی طبق اولویت ۳: خال غیر حکم با ۳ یا کمتر کارت');
          return weakestCard(suitCards);
        }
      }
      // اولویت ۴: ضعیف‌ترین کارت غیر حکم
      final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
      if (nonHokmCards.isNotEmpty) {
        print(
            '[$name][$direction] (اولین نفر/دست اول): بازی طبق اولویت ۴: ضعیف‌ترین کارت غیر حکم');
        return weakestCard(nonHokmCards);
      }
      // اگر فقط حکم داری، ضعیف‌ترین حکم را بازی کن
      print(
          '[$name][$direction] (اولین نفر/دست اول): بازی طبق اولویت ۵: فقط حکم داری، ضعیف‌ترین حکم بازی می‌شود');
      return weakestCard(hand);
    } else {
      // دست‌های بعدی (کمتر از ۱۳ کارت)
      // اولویت ۱: آس غیر حکم
      final nonHokmAces =
          hand.where((c) => c.suit != hokm && c.rank == Rank.ace).toList();
      if (nonHokmAces.isNotEmpty) {
        print(
            '[$name][$direction] ( نفر اول /دست‌های بعدی): اولویت ۱: آس غیر حکم');
        return nonHokmAces.first;
      }
      // اولویت ۲: قوی‌ترین کارت‌های حکم که قطعا برنده‌اند
      final playedCards = tableHistory.expand((l) => l).toList() + table;

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
                  '[$name][$direction] ( نفر اول /دست‌های بعدی): اولویت ۳: قوی‌ترین کارت غیر حکم که قطعا برنده است');
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
            '[$name][$direction] ( نفر اول /دست‌های بعدی): اولویت ۴: یار خالی را برید و تو هم آن خال را داری');
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
        int partnerOffset = (partnerDir.index - starterDirection.index + 4) % 4;
        final partnerCard = lastHand[partnerOffset];
        // اگر یار خال leadSuit را نداشته و حکم نزده
        if (partnerCard.suit != leadSuit &&
            partnerCard.suit != hokm &&
            leadSuit != hokm) {
          final mySuitCards = hand.where((c) => c.suit == leadSuit).toList();
          if (mySuitCards.isNotEmpty) {
            print(
                '[$name][$direction] ( نفر اول /دست‌های بعدی): اولویت ۴.۵: یار خال را رد کرده، آن خال را بازی کن');
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
        int partnerOffset = (partnerDir.index - starterDirection.index + 4) % 4;
        final partnerCard = lastHand[partnerOffset];
        // اگر یار خال leadSuit را نداشته و حکم نزده و کارت برنده بوده
        if (partnerCard.suit != leadSuit && partnerCard.suit != hokm) {
          // آیا کارت یار قوی‌ترین کارت باقی‌مانده آن خال بوده؟
          final playedSuitCards = tableHistory
              .expand((l) => l)
              .where((c) => c.suit == leadSuit)
              .toList();
          if (isStrongestCard(partnerCard, playedSuitCards)) {
            final mySuitCards = hand.where((c) => c.suit == leadSuit).toList();
            if (mySuitCards.isNotEmpty) {
              print(
                  '[$name][$direction] ( نفر اول /دست‌های بعدی): اولویت ۴.۷: یار کارت برنده خال غیر حکم را رد کرده، آن خال را بازی کن تا یار برش بزند');
              return weakestCard(mySuitCards);
            }
          }
        }
      }
      // اولویت ۵: اگر حریف قبلاً یک خال را با حکم بریده، آن خال را بازی نکن
      // final cutSuits = opponentPreviouslyCutSuitWithHokm(
      //   tableHistory: tableHistory,
      //   hokm: hokm,
      //   myDirection: direction,
      //   players: teams.expand((t) => [t.playerA, t.playerB]).toList(),
      // );
      // for (final suit in cutSuits) {
      //   final mySuitCards = hand.where((c) => c.suit == suit).toList();
      //   if (mySuitCards.isNotEmpty) {
      //     // اگر کارت دیگری داری، آن خال را بازی نکن
      //     final otherSuits = hand.where((c) => c.suit != suit).toList();
      //     if (otherSuits.isNotEmpty) {
      //       print(
      //           '[$name][$direction] (اولین نفر/دست‌های بعدی): بازی طبق اولویت ۵: حریف قبلاً این خال را بریده، آن خال را بازی نکن');
      //       return weakestCard(otherSuits);
      //     } else {
      //       print(
      //           '[$name][$direction] (اولین نفر/دست‌های بعدی): فقط همین خال را داری که قبلاً بریده شده، ضعیف‌ترین کارت همین خال بازی می‌شود');
      //       return weakestCard(mySuitCards);
      //     }
      //   }
      // }
//! اولویت ۲: قوی‌ترین کارت حکم که قطعا برنده است
      final playedHokmRanks =
          playedCards.where((c) => c.suit == hokm).map((c) => c.rank).toList();
      final myHokmCards = hand.where((c) => c.suit == hokm).toList();
      for (final card in myHokmCards) {
        bool isStrongest = Rank.values
            .where((r) => r.index < card.rank.index)
            .every((r) => playedHokmRanks.contains(r));
        if (isStrongest) {
          print(
              '[$name][$direction] ( نفر اول /دست‌های بعدی): اولویت ۲: قوی‌ترین کارت حکم که قطعا برنده است');
          return card;
        }
      }
      // اولویت ۶: ضعیف‌ترین کارت غیر حکم
      final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
      if (nonHokmCards.isNotEmpty) {
        print(
            '[$name][$direction] ( نفر اول /دست‌های بعدی): اولویت ۶: ضعیف‌ترین کارت غیر حکم');
        return weakestCard(nonHokmCards);
      }
      // اگر فقط حکم داری، ضعیف‌ترین حکم را بازی کن
      print(
          '[$name][$direction] ( نفر اول /دست‌های بعدی): اولویت ۷: فقط حکم داری، ضعیف‌ترین حکم بازی می‌شود');
      return weakestCard(hand);
    }
  }

//! هوش مصنوعی نفر دوم
  GameCard secondCard(Suit hokm, List<List<GameCard>> tableHistory,
      List<GameCard> table, List<Team> teams) {
    // نفر دوم هستی
    final firstCard = table.first;
    //!  کارتهای همان خال
    final sameSuitCards = hand.where((c) => c.suit == firstCard.suit).toList();

    // اگر کارتی از همان خال داری که قوی‌ترین کارت باقی‌مانده است، آن را بازی کن
    for (final card in sameSuitCards) {
      final playedSuitRanks = tableHistory
          .expand((l) => l)
          .where((c) => c.suit == firstCard.suit)
          .map((c) => c.rank)
          .toList();
      bool isStrongest = Rank.values
          .where((r) => r.index < card.rank.index)
          .every((r) => playedSuitRanks.contains(r));
      if (isStrongest) {
        print(
            '[$name][$direction] (نفر دوم): قوی‌ترین کارت میز را دارم و بازی می‌کنم');
        return card;
      }
    }
    // اگر کارت همان خال را داری ولی قوی‌ترین نیست، ضعیف‌ترین کارت همان خال را بازی کن
    if (sameSuitCards.isNotEmpty) {
      print(
          '[$name][$direction] (نفر دوم): فقط کارت ضعیف همان خال را دارم، ضعیف‌ترین کارت همان خال را بازی می‌کنم');
      return weakestCard(sameSuitCards);
    }
    // ۴. اگر هیچ کارتی از آن خال نداری
    if (sameSuitCards.isEmpty) {
      final hokmCards = hand.where((c) => c.suit == hokm).toList();
      if (hokmCards.isNotEmpty) {
        print(
            '[$name][$direction] (نفر دوم): هیچ کارتی از آن خال نداری و حکم داری، ضعیف‌ترین حکم را بازی کن');
        return weakestCard(hokmCards);
      } else {
        print(
            '[$name][$direction] (نفر دوم): هیچ کارتی از آن خال و حکم نداری، ضعیف‌ترین کارت غیرحکم را بازی کن');
        final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
        return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
      }
    }
    return weakestCard(hand);
  }

//! هوش مصنوعی نفر سوم
  GameCard thirdCard(Suit hokm, List<List<GameCard>> tableHistory,
      List<GameCard> table, List<Team> teams) {
    //! نفر اول (یار)
    final firstCard = table[0];
    //! نفر دوم
    final secondCard = table[1];
    //! خال میز
    final leadSuit = firstCard.suit;
    //! کارتهای همان خال
    final sameSuitCards = hand.where((c) => c.suit == leadSuit).toList();
    //! کارتهای حکم
    final hokmCards = hand.where((c) => c.suit == hokm).toList();
    //! کارتهای غیر حکم
    final nonHokmCards = hand.where((c) => c.suit != hokm).toList();

    // اگر نفر دوم با حکم زده و تو کارت همان خال داری، شانسی برای بردن نداری
    if (secondCard.suit == hokm &&
        leadSuit != hokm &&
        sameSuitCards.isNotEmpty) {
      print(
          '[$name][$direction] (نفر سوم): نفر دوم بریده، ضعیف‌ترین همان خال را بازی می‌کنم');
      return weakestCard(sameSuitCards);
    }

    // --- منطق جدید: آیا کارت یار واقعاً قوی‌ترین کارت باقی‌مانده است؟ ---
    bool partnerIsTrulyWinning = false;
    {
      // همه کارت‌های بازی‌شده تا الان + کارت‌های روی میز فعلی
      final playedCards = tableHistory.expand((l) => l).toList() + table;
      // همه کارت‌های ممکن از آن خال
      final allSuitCards = Rank.values
          .map((rank) => GameCard(suit: leadSuit, rank: rank))
          .toList();
      // کارت‌های باقی‌مانده از آن خال (در دست دیگران)
      final remainingSuitCards = allSuitCards
          .where((c) =>
              !playedCards
                  .any((pc) => pc.suit == c.suit && pc.rank == c.rank) &&
              !hand.any((hc) => hc.suit == c.suit && hc.rank == c.rank))
          .toList();
      // اگر هیچ کارت قوی‌تری نسبت به کارت یار در کارت‌های باقی‌مانده نبود، پس یار واقعاً برنده است
      partnerIsTrulyWinning =
          remainingSuitCards.every((c) => c.rank.index < firstCard.rank.index);
      print('[DEBUG][thirdCard] partnerIsTrulyWinning: '
          '\u001b[33m$partnerIsTrulyWinning\u001b[0m, '
          'firstCard: $firstCard, remainingSuitCards: $remainingSuitCards, hand: $hand');
    }
    // اگر کارت همان خال را داری
    if (sameSuitCards.isNotEmpty) {
      final maxOnTable = strongestCard([firstCard, secondCard],
          hokm: hokm == leadSuit ? null : hokm);
      final partnerIsCurrentlyWinning = maxOnTable == firstCard;
      // اگر یار واقعاً برنده است
      if (partnerIsTrulyWinning) {
        // فقط ضعیف‌ترین کارت همان خال را بازی کن
        print(
            '[$name][$direction] (نفر سوم): یار واقعاً برنده است، ضعیف‌ترین همان خال را بازی می‌کنم');
        return weakestCard(sameSuitCards);
      } else if (partnerIsCurrentlyWinning) {
        // اگر کارت برنده داری، قوی‌ترین کارت برنده را بازی کن، وگرنه ضعیف‌ترین همان خال
        final winning = sameSuitCards
            .where((c) => c.rank.index < maxOnTable.rank.index)
            .toList();
        if (winning.isNotEmpty) {
          print(
              '[$name][$direction] (نفر سوم): کارت همان خال را داری که می‌تواند برنده شود');
          return strongestCard(winning);
        } else {
          print(
              '[$name][$direction] (نفر سوم): کارت قوی خال را نداری، ضعیف‌ترین کارت همان خال را بازی کن');
          return weakestCard(sameSuitCards);
        }
      } else {
        // اگر یار برنده نیست، سعی کن دست را ببری
        final winning = sameSuitCards
            .where((c) => c.rank.index < maxOnTable.rank.index)
            .toList();
        if (winning.isNotEmpty) {
          print(
              '[$name][$direction] (نفر سوم): کارت قوی‌تر خال را داری که برنده شود، قوی‌ترین کارت برنده را بازی کن');
          return strongestCard(winning);
        } else {
          print(
              '[$name][$direction] (نفر سوم): فقط کارت ضعیف همان خال را داری، ضعیف‌ترین کارت همان خال را بازی کن');
          return weakestCard(sameSuitCards);
        }
      }
    } else {
      // کارت همان خال را نداری
      if (partnerIsTrulyWinning) {
        print(
            '[$name][$direction] (نفر سوم): کارت خال ندارم و یار واقعاً برنده است، ضعیف‌ترین غیرحکم را بازی می‌کنم');
        return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
      }
      // اگر حکم داری و می‌توانی با حکم قوی‌تر دست را ببری
      final tableHokms =
          [firstCard, secondCard].where((c) => c.suit == hokm).toList();
      final maxHokmOnTable =
          tableHokms.isNotEmpty ? strongestCard(tableHokms) : null;
      if (hokmCards.isNotEmpty) {
        if (maxHokmOnTable != null) {
          // آیا حکمی داری که قوی‌تر از حکم روی میز باشد؟
          final winningHokms = hokmCards
              .where((c) => c.rank.index < maxHokmOnTable.rank.index)
              .toList();
          if (winningHokms.isNotEmpty) {
            print('[$name][$direction] (نفر سوم): با حکم قوی‌تر دست را می‌برم');
            return weakestCard(winningHokms);
          } else {
            print(
                '[$name][$direction] (نفر سوم): حکم داری اما نمی‌توانی دست را ببری، ضعیف‌ترین حکم را بازی می‌کنم');
            return weakestCard(hokmCards);
          }
        } else {
          // هیچ حکمی روی میز نیست، پس هر حکمی برنده است
          print(
              '[$name][$direction] (نفر سوم): هیچ حکمی روی میز نیست، با حکم می‌برم');
          return weakestCard(hokmCards);
        }
      }
      print(
          '[$name][$direction] (نفر سوم): نه حکم دارم نه همان خال، ضعیف‌ترین غیرحکم را بازی می‌کنم');
      return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
    }
  }

//! هوش مصنوعی نفر چهارم
  GameCard fourthCard(Suit hokm, List<List<GameCard>> tableHistory,
      List<GameCard> table, List<Team> teams) {
    final firstCard = table[0];
    final secondCard = table[1]; // یار نفر چهارم
    final thirdCard = table[2];
    final leadSuit = firstCard.suit;
    final sameSuitCards = hand.where((c) => c.suit == leadSuit).toList();
    final hokmCards = hand.where((c) => c.suit == hokm).toList();
    final nonHokmCards = hand.where((c) => c.suit != hokm).toList();
    // بررسی برنده فعلی روی میز
    final currentWinner = strongestCard([firstCard, secondCard, thirdCard],
        hokm: hokm == leadSuit ? null : hokm);
    // کارت یار (نفر دوم)
    final partnerCard = secondCard;

    // اگر نفر سوم با حکم زده و تو کارت همان خال داری، شانسی برای بردن نداری
    if (thirdCard.suit == hokm &&
        leadSuit != hokm &&
        sameSuitCards.isNotEmpty) {
      print(
          '[$name][$direction] (نفر چهارم): نفر سوم بریده، ضعیف‌ترین همان خال را بازی می‌کنم');
      return weakestCard(sameSuitCards);
    }

    // اگر کارت همان خال داری
    if (sameSuitCards.isNotEmpty) {
      // اگر کارت یار بزرگ‌ترین کارت روی میز است و نفر سوم نبریده
      if (currentWinner == partnerCard && thirdCard.suit != hokm) {
        print(
            '[$name][$direction] (نفر چهارم): یار برنده است و نفر سوم نبریده، ضعیف‌ترین همان خال را بازی می‌کنم');
        return weakestCard(sameSuitCards);
      }
      // اگر می‌توانی با همان خال دست را ببری
      final winning = sameSuitCards
          .where((c) => c.rank.index < currentWinner.rank.index)
          .toList();
      if (winning.isNotEmpty) {
        print('[$name][$direction] (نفر چهارم): با همان خال دست را می‌برم');
        return weakestCard(winning);
      } else {
        print(
            '[$name][$direction] (نفر چهارم): فقط همان خال را دارم، ضعیف‌ترین همان خال را بازی می‌کنم');
        return weakestCard(sameSuitCards);
      }
    } else {
      // اگر کارت همان خال نداری
      // اگر یار برنده است، ضعیف‌ترین غیرحکم را بازی کن
      if (currentWinner == partnerCard) {
        print(
            '[$name][$direction] (نفر چهارم): کارت همان خال ندارم و یار برنده است، ضعیف‌ترین غیرحکم را بازی می‌کنم');
        return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
      }
      // اگر یار با حکم بریده و قوی‌ترین حکم روی میز است، کارت ضعیف بازی کن
      if (partnerCard.suit == hokm) {
        final tableHokms = [firstCard, secondCard, thirdCard]
            .where((c) => c.suit == hokm)
            .toList();
        final maxHokmOnTable =
            tableHokms.isNotEmpty ? strongestCard(tableHokms) : null;
        if (maxHokmOnTable != null && partnerCard == maxHokmOnTable) {
          print(
              '[$name][$direction] (نفر چهارم): یار با حکم بریده و برنده است، ضعیف‌ترین کارت غیرحکم را بازی می‌کنم');
          return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
        }
      }
      // اگر حکم داری و می‌توانی با حکم قوی‌تر دست را ببری
      final tableHokms = [firstCard, secondCard, thirdCard]
          .where((c) => c.suit == hokm)
          .toList();
      final maxHokmOnTable =
          tableHokms.isNotEmpty ? strongestCard(tableHokms) : null;
      if (hokmCards.isNotEmpty) {
        if (maxHokmOnTable != null) {
          final winningHokms = hokmCards
              .where((c) => c.rank.index < maxHokmOnTable.rank.index)
              .toList();
          if (winningHokms.isNotEmpty) {
            print(
                '[$name][$direction] (نفر چهارم): با حکم قوی‌تر دست را می‌برم');
            return weakestCard(winningHokms);
          } else {
            print(
                '[$name][$direction] (نفر چهارم): حکم داری اما نمی‌توانی دست را ببری، ضعیف‌ترین حکم را بازی می‌کنم');
            return weakestCard(
                nonHokmCards.isNotEmpty ? nonHokmCards : hokmCards);
          }
        } else {
          // هیچ حکمی روی میز نیست، پس هر حکمی برنده است
          print(
              '[$name][$direction] (نفر چهارم): هیچ حکمی روی میز نیست، با حکم می‌برم');
          return weakestCard(hokmCards);
        }
      }
      print(
          '[$name][$direction] (نفر چهارم): نه حکم دارم نه همان خال، ضعیف‌ترین غیرحکم را بازی می‌کنم');
      return weakestCard(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
    }
  }

  //! متد خصوصی برای گرفتن کارت‌های یک خال
  List<GameCard> _suitCards(Suit suit) =>
      hand.where((c) => c.suit == suit).toList();

  //! متد خصوصی برای گرفتن کارت‌های همان خال
  List<GameCard> _sameSuitCards(GameCard card) => _suitCards(card.suit);

  //! متد خصوصی برای گرفتن کارت‌های همه خال‌ها
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
    required Direction starterDirection,
  }) {
    // منطق بازی بازیکن انسانی توسط UI کنترل می‌شود
    throw UnimplementedError('بازی بازیکن انسانی توسط UI انجام می‌شود');
  }
}
