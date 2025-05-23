import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/models/card.dart';
import 'package:persian_hokm/widgets/card_widget.dart';
import 'package:persian_hokm/screens/settings_screen.dart';

// -------------------- منطق بازی حکم (تبدیل شده از کاتلین) --------------------

/// جهت‌های بازی
/// جهت‌ها به ترتیب: پایین (بازیکن انسانی)، راست، بالا، چپ
/// مقدار عددی برای تعیین ترتیب توزیع کارت و نوبت‌دهی
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

  void addHand(List<GameCard> newHand) {
    hand.clear();
    hand.addAll(newHand);
  }

  /// متد بازی کردن کارت (باید توسط زیرکلاس‌ها پیاده‌سازی شود)
  GameCard play({
    required List<GameCard> table,
    required List<List<GameCard>> tableHistory,
    required List<Team> teams,
    required Suit hokm,
  });

  /// انتخاب خال حکم توسط هوش مصنوعی
  Suit determineHokm() {
    if (hand.isEmpty) throw Exception("Hand is empty");

    // دیکشنری امتیازدهی کارت‌ها (به صورت تاکتیکی)
    final rankScore = {
      Rank.ace: 8,
      Rank.king: 6,
      Rank.queen: 5,
      Rank.jack: 4,
      Rank.ten: 3,
      Rank.nine: 2,
      Rank.eight: 1,
      Rank.seven: 1,
      Rank.six: 0,
      Rank.five: 0,
      Rank.four: 0,
      Rank.three: 0,
      Rank.two: 0,
    };

    final Map<Suit, int> suitScore = {};
    final Map<Suit, int> suitCount = {};

    // محاسبه امتیاز و تعداد کارت‌های هر خال
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

  // Suit determineHokm() {
  //   final groupWithCounts = <Suit, int>{};
  //   for (var card in hand) {
  //     groupWithCounts[card.suit] = (groupWithCounts[card.suit] ?? 0) + 1;
  //   }
  //   final sorted = groupWithCounts.entries.toList()
  //     ..sort((a, b) => b.value.compareTo(a.value));
  //   if (sorted[0].value >= 3) return sorted[0].key;
  //   if (sorted.length > 1 && sorted[0].value > sorted[1].value) {
  //     return sorted[0].key;
  //   }
  //   if (sorted.length > 1) {
  //     final first = hand
  //         .where((c) => c.suit == sorted[0].key)
  //         .reduce((a, b) => a.rank.index < b.rank.index ? b : a);
  //     final second = hand
  //         .where((c) => c.suit == sorted[1].key)
  //         .reduce((a, b) => a.rank.index < b.rank.index ? b : a);
  //     return first.rank.index > second.rank.index
  //         ? sorted[0].key
  //         : sorted[1].key;
  //   }
  //   return hand.first.suit;
  // }
}

/// بازیکن هوش مصنوعی
class PlayerAI extends Player {
  final int aiLevel;
  final bool isPartner;

  PlayerAI(
    String name,
    Direction direction,
    List<GameCard> cards, {
    required this.aiLevel,
    required this.isPartner,
  }) : super(name, cards, direction);

  @override
  GameCard play({
    required List<GameCard> table,
    required List<List<GameCard>> tableHistory,
    required List<Team> teams,
    required Suit hokm,
  }) {
    final effectiveLevel = isPartner ? 3 : aiLevel;
    switch (effectiveLevel) {
      case 1:
        return _basicPlay(table, hokm);
      case 2:
        return _intermediatePlay(table, hokm);
      case 3:
      default:
        return _advancedPlay(table, hokm, tableHistory, teams);
    }
  }

  GameCard _basicPlay(List<GameCard> table, Suit hokm) {
    if (table.isEmpty) {
      final nonHokms = hand.where((c) => c.suit != hokm).toList();
      return nonHokms.isNotEmpty ? _strongest(nonHokms) : _strongest(hand);
    }

    final sameSuit = _sameSuitCards(table.first);
    if (sameSuit.isNotEmpty) {
      return _weakest(sameSuit);
    }

    final hokms = _suitCards(hokm);
    return hokms.isNotEmpty ? _weakest(hokms) : _weakest(hand);
  }

  GameCard _intermediatePlay(List<GameCard> table, Suit hokm) {
    if (table.isEmpty) return _strongest(hand);

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
    final playedCards = tableHistory.expand((list) => list).toList();
    final seenCards = [...playedCards, ...table];
    final unseenCards = allPossibleCards()
        .where(
            (c) => !seenCards.any((p) => p.suit == c.suit && p.rank == c.rank))
        .toList();

    if (table.isEmpty) {
      // شروع‌کننده: ضعیف‌ترین کارت غیرحکم یا ضعیف‌ترین کارت
      final nonHokms = hand.where((c) => c.suit != hokm).toList();
      return nonHokms.isNotEmpty ? _weakest(nonHokms) : _weakest(hand);
    }

    final leadSuit = table.first.suit;
    final sameSuit = _suitCards(leadSuit);

    if (sameSuit.isNotEmpty) {
      // اگر کارت هم‌خال داری
      final maxOnTable =
          _strongest(table.where((c) => c.suit == leadSuit).toList());
      final canWin =
          sameSuit.where((c) => c.rank.index < maxOnTable.rank.index).toList();
      // اگر می‌توانی دست را ببری، ضعیف‌ترین کارت برنده را بازی کن
      if (canWin.isNotEmpty) return _strongest(canWin);
      // اگر نمی‌توانی ببری، ضعیف‌ترین کارت را بازی کن
      return _weakest(sameSuit);
    }

    // کارت هم‌خال نداری
    final hokmCards = _suitCards(hokm);
    final nonHokmCards = hand.where((c) => c.suit != hokm).toList();

    // آیا کسی روی میز حکم انداخته؟
    final maxHokmOnTable = table.where((c) => c.suit == hokm);
    final maxHokm =
        maxHokmOnTable.isNotEmpty ? _strongest(maxHokmOnTable.toList()) : null;

    // اگر حکم داری
    if (hokmCards.isNotEmpty) {
      // اگر کسی روی میز حکم انداخته و می‌توانی با حکم دست را ببری
      if (maxHokm != null) {
        final winHokm =
            hokmCards.where((c) => c.rank.index < maxHokm.rank.index).toList();
        if (winHokm.isNotEmpty) {
          // با ضعیف‌ترین حکم برنده ببر
          return _strongest(winHokm);
        } else {
          // نمی‌توانی ببری، ضعیف‌ترین حکم را بازی کن
          return _weakest(hokmCards);
        }
      } else {
        // کسی روی میز حکم نینداخته
        // اگر کارت غیرحکم داری، با ضعیف‌ترین کارت غیرحکم رد کن
        if (nonHokmCards.isNotEmpty) return _weakest(nonHokmCards);
        // اگر فقط حکم داری، ضعیف‌ترین حکم را بازی کن
        return _weakest(hokmCards);
      }
    }

    // اگر حکم نداری، ضعیف‌ترین کارت غیرحکم را بازی کن
    return _weakest(nonHokmCards.isNotEmpty ? nonHokmCards : hand);
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
      final hokmCards = table.where((c) => c.suit == hokm).toList();
      if (hokmCards.isNotEmpty) {
        return _getWinner(hokmCards);
      } else {
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

class GameController extends GetxController {
  /// لیست کارت های بازی
  final cards = <GameCard>[].obs;

  /// اندیس کارت فعلی
  final currentCardIndex = 0.obs;

  /// آیا باید تاج و دایره را نشان دهد
  final showTajAndCircle = false.obs;

  /// آیا باید کارت ها را نشان دهد
  final showCards = false.obs;

  /// آیا باید دکمه شروع بازی را نشان دهد
  final showStartButton = true.obs;

  /// موقعیت های کارت ها
  final cardPositions = {
    'left': 0.0.obs,
    'right': 0.0.obs,
    'top': 0.0.obs,
  }.obs;

  /// کارت های بازیکنان
  final playerCards = {
    'bottom': <GameCard>[].obs,
    'right': <GameCard>[].obs,
    'top': <GameCard>[].obs,
    'left': <GameCard>[].obs,
  }.obs;

  /// بازیکن حاکم
  final hokmPlayer = ''.obs;

  /// آیا در حال توزیع کارت هست
  final isDistributing = false.obs;

  /// خال حکم انتخاب شده
  final selectedHokm = Rxn<Suit>();

  /// آیا دیالوگ انتخاب حکم نمایش داده شده است
  final showHokmDialog = false.obs;

  /// آیا مرحله اول تقسیم کارت‌ها انجام شده است
  final isFirstDistributionDone = false.obs;

  /// آیا مرحله دوم تقسیم کارت‌ها انجام شده است
  final isSecondDistributionDone = false.obs;

  /// آیا مرحله سوم تقسیم کارت‌ها انجام شده است
  final isThirdDistributionDone = false.obs;

  /// بازیکن فعلی که نوبت اوست
  final currentPlayer = ''.obs;

  /// کارت‌های روی زمین
  final tableCards = <String, GameCard>{}.obs;

  /// آیا نوبت بازیکن پایین است
  final isBottomPlayerTurn = false.obs;

  /// آیا بازی شروع شده است
  final isGameStarted = false.obs;

  /// امتیاز تیم‌ها
  final teamScores = {
    'team1': 0.obs, // بازیکن پایین و بالا
    'team2': 0.obs, // بازیکن راست و چپ
  }.obs;

  /// خال اول دست
  final firstSuit = Rxn<Suit>();

  /// منطق اصلی بازی حکم
  late GameLogic game;

  @override
  void onInit() {
    super.onInit();
    game = GameLogic();
    _initializeCards();
  }

  /// تخصیص کارت ها به بازیکنان
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
    cards.addAll(game._getNewDeck());
    cards.shuffle(Random());
  }

  /// شروع بازی
  void startGame() async {
    if (kDebugMode) {
      print('Starting game...');
    }
    showStartButton.value = false;
    showCards.value = true;
    isGameStarted.value = false;
    await _distributeCardsForHakem();
  }

  /// پخش مرحله‌ای کارت‌ها برای تعیین حاکم
  Future<void> _distributeCardsForHakem() async {
    cards.clear();
    cards.addAll(game._getNewDeck());
    cards.shuffle(Random());
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
      cards.clear();
      cards.addAll(game._getNewDeck());
      cards.shuffle(Random());
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

  /// همگام‌سازی دست بازیکنان با UI و منطق بازی
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

  /// ترتیب توزیع کارت بر اساس حاکم
  List<Direction> _getDistributionOrder(Direction start) {
    return List.generate(4, (i) => Direction.values[(start.index + i) % 4]);
  }

  /// توزیع کارت به صورت تک‌تک برای هر بازیکن (۵ یا ۴ کارت)
  Future<void> _dealCardsStepByStep(int numCards) async {
    final order = _getDistributionOrder(game.hakem);
    for (final dir in order) {
      for (int i = 0; i < numCards; i++) {
        // کارت را از deck بردار و به دست بازیکن و UI اضافه کن
        final card = game.deck.removeLast();
        game.hands[dir.index].add(card);
        card.player = game.players.isNotEmpty ? game.players[dir.index] : null;
        playerCards[_directionToString(dir)]?.add(card);
        // فقط داده‌ها sync می‌شود، هیچ تغییری در cardPositions یا پوزیشن کارت‌ها داده نمی‌شود
        update();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    // بعد از هر مرحله sync کامل
    _syncHandsWithUI();
  }

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

  /// تبدیل enum Direction به string برای UI
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

  /// انتخاب حکم توسط human یا AI
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

  /// مرتب‌سازی کارت‌های بازیکن پایین بعد از تکمیل دست
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

  /// بازی کردن کارت
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

  /// بازی کردن کارت توسط کامپیوتر
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

  /// پایان دست و بروزرسانی UI و امتیاز
  void _endHandUI(String winner) async {
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

  /// پایان بازی
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

  /// بررسی امکان بازی کارت
  bool canPlayCard(GameCard card) {
    // اگر نوبت بازیکن پایین نیست و بازیکن پایین نیست، اجازه بازی بده
    if (!isBottomPlayerTurn.value && currentPlayer.value != 'bottom') {
      return true;
    }

    // اگر نوبت بازیکن پایین نیست، اجازه بازی نده
    if (!isBottomPlayerTurn.value) {
      if (kDebugMode) {
        print('Not bottom player turn');
      }
      return false;
    }

    if (tableCards.isEmpty) {
      if (kDebugMode) {
        print('First card of the hand');
      }
      return true;
    }

    // اگر کارت از خال اول دست نباشد و بازیکن کارت از خال اول دست داشته باشد، نمی‌تواند کارت دیگری بازی کند
    if (card.suit != firstSuit.value) {
      final hasFirstSuitCard =
          playerCards['bottom']!.any((c) => c.suit == firstSuit.value);
      if (hasFirstSuitCard) {
        if (kDebugMode) {
          print('Player has first suit card but trying to play different suit');
        }
        return false;
      }
    }

    if (kDebugMode) {
      print('Card can be played');
    }
    return true;
  }

  /// حذف کردن کارت بالای پشته
  void removeTopCard() {
    if (currentCardIndex.value < cards.length) {
      currentCardIndex.value++;
    }
  }

  /// گرفتن نام بازیکن
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

class GameScreen extends StatelessWidget {
  GameScreen({super.key});

  final controller = Get.put(GameController());
  final settingsController = Get.put(SettingsController());

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
                          fit: BoxFit.cover,
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

  Container bkgText({required Widget child}) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child);
  }

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
                          !controller.isGameStarted.value)
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
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Stack(children: [
                                  for (int i = 0;
                                      i <
                                          controller
                                              .playerCards['bottom']!.length;
                                      i++)
                                    Positioned(
                                      left: i *
                                          (MediaQuery.of(context).size.width *
                                              0.0526),
                                      child: GestureDetector(
                                        onTap: () {
                                          final card = controller
                                              .playerCards['bottom']![i];
                                          if (kDebugMode) {
                                            print(
                                                'Card tapped: ${card.toString()}');
                                            print(
                                                'Is bottom player turn: ${controller.isBottomPlayerTurn.value}');
                                            print(
                                                'Can play card: ${controller.canPlayCard(card)}');
                                          }
                                          if (controller
                                                  .isBottomPlayerTurn.value &&
                                              controller.canPlayCard(card)) {
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

  Widget cardLeft() {
    return Builder(
        builder: (context) => Obx(() => Positioned(
            left: (controller.cardPositions['left']?.value ?? 50) + 1,
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

  Widget cardRight() {
    return Builder(
      builder: (context) => Obx(
        () => Positioned(
          right: (controller.cardPositions['right']?.value ?? 50) + 1,
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

  List<Widget> tajAnCir() {
    return [
      Image.asset(
        'assets/drawables/taj.png',
        height: 20,
      ),
    ];
  }

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
