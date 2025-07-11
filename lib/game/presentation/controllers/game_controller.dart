import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:persian_hokm/game/core/game_logic.dart';
import 'package:persian_hokm/game/models/enums.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/models/player.dart';
import 'package:persian_hokm/game/models/team.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';
import 'package:persian_hokm/game/presentation/widgets/animated_card.dart';
import 'package:persian_hokm/game/presentation/widgets/played_animated_card.dart';

/// کنترلر اصلی بازی حکم
class GameController extends GetxController {
  final cards = <GameCard>[].obs;
  final currentCardIndex = 0.obs;
  final showTajAndCircle = false.obs;
  final showCards = false.obs;
  final showStartButton = true.obs;
  final cardPositions = {
    'left': 0.0.obs,
    'right': 0.0.obs,
    'top': 0.0.obs,
  }.obs;
  final playerCards = {
    'bottom': <GameCard>[].obs,
    'right': <GameCard>[].obs,
    'top': <GameCard>[].obs,
    'left': <GameCard>[].obs,
  }.obs;
  final hokmPlayer = ''.obs;
  final isDistributing = false.obs;
  final selectedHokm = Rxn<Suit>();
  final showHokmDialog = false.obs;
  final isFirstDistributionDone = false.obs;
  final isSecondDistributionDone = false.obs;
  final isThirdDistributionDone = false.obs;
  final currentPlayer = ''.obs;
  final tableCards = <String, GameCard>{}.obs;
  final isBottomPlayerTurn = false.obs;
  final isGameStarted = false.obs;
  final teamScores = {
    'team1': 0.obs,
    'team2': 0.obs,
  }.obs;
  final firstSuit = Rxn<Suit>();
  late GameLogic game;
  final animatedCards = <dynamic>[].obs;
  final animatedPlayedCards = <dynamic>[].obs;
  final teamSets = {
    'team1': 0.obs,
    'team2': 0.obs,
  }.obs;
  final team1WonHands = <int>[].obs;
  final team2WonHands = <int>[].obs;
  BuildContext get context => Get.context!;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Direction? currentHakemDir;
  bool isFirstGame = true;
  bool _isActive = true;

  /// پخش صدای مورد نظر با نام داده شده
  Future<void> playSound(String name) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('songs/$name'));
    } catch (_) {}
  }

  /// مقداردهی اولیه کنترلر و بازی
  @override
  void onInit() {
    super.onInit();
    game = GameLogic();
    _initializeCards();
  }

  /// مقداردهی اولیه کارت‌ها و وضعیت بازی
  void _initializeCards() {
    tableCards.clear();
    animatedPlayedCards.clear();
    firstSuit.value = null;
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
    final newDeck = game.getNewDeck();
    newDeck.shuffle(Random());
    cards.addAll(newDeck);
    game.deck = List.from(newDeck);
  }

  /// شروع بازی و تعیین حاکم
  void startGame() async {
    snackMessage(title: 'انتخاب حاکم');
    showStartButton.value = false;
    showCards.value = true;
    isGameStarted.value = false;
    if (isFirstGame) {
      await _distributeCardsForHakem();
      isFirstGame = false;
    } else {
      await startGameWithHakem(currentHakemDir!);
    }
  }

  /// شروع بازی با حاکم مشخص
  Future<void> startGameWithHakem(Direction hakemDir) async {
    for (var h in game.hands) {
      h.clear();
    }
    game.tableHistory.clear();
    showStartButton.value = false;
    showCards.value = true;
    isGameStarted.value = false;
    currentHakemDir = hakemDir;
    hokmPlayer.value = _directionToString(hakemDir);
    game.hakem = hakemDir;
    final newDeck = game.getNewDeck();
    newDeck.shuffle(Random());
    cards.clear();
    cards.addAll(newDeck);
    game.deck = List.from(newDeck);
    for (var list in playerCards.values) {
      list.clear();
    }
    showTajAndCircle.value = false;
    selectedHokm.value = null;
    showHokmDialog.value = false;
    isFirstDistributionDone.value = false;
    isSecondDistributionDone.value = false;
    isThirdDistributionDone.value = false;
    cardPositions.value = {
      'left': (-50.0).obs,
      'right': (-100.0).obs,
      'top': (-75.0).obs,
    };
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
    await _dealCardsStepByStep(5);
    if (hakemDir == Direction.bottom) {
      showHokmDialog.value = true;
    } else {
      final aiHokm = game.players[hakemDir.index].determineHokm();
      selectHokm(aiHokm);
    }
  }

  /// توزیع کارت برای تعیین حاکم
  Future<void> _distributeCardsForHakem() async {
    for (var h in game.hands) {
      h.clear();
    }
    game.tableHistory.clear();
    final newDeck = game.getNewDeck();
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
      if (!_isActive) return;
      final currentCard = cards[currentCardIndex];
      final currentPlayer = distributionOrder[currentPlayerIndex];
      playSound('pakhsh.mp3');
      final animData =
          AnimatedCard(card: currentCard, targetPosition: currentPlayer);
      animatedCards.add(animData);
      update();
      await Future.delayed(const Duration(milliseconds: 350));
      if (!_isActive) return;
      playerCards[currentPlayer]?.add(currentCard);
      animatedCards.removeWhere((a) => a.key == animData.key);
      cards.removeAt(currentCardIndex);
      update();
      await Future.delayed(const Duration(milliseconds: 60));
      if (!_isActive) return;
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
      currentPlayerIndex = (currentPlayerIndex + 1) % 4;
    }
    if (hakemFound) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_isActive) return;
      for (var list in playerCards.values) {
        list.clear();
      }
      final newDeck = game.getNewDeck();
      newDeck.shuffle(Random());
      cards.clear();
      cards.addAll(newDeck);
      game.deck = List.from(newDeck);
      cardPositions.value = {
        'left': (-50.0).obs,
        'right': (-100.0).obs,
        'top': (-75.0).obs,
      };
      game.hakem = _stringToDirection(hokmPlayer.value);
      currentHakemDir = game.hakem;
      await _dealCardsStepByStep(5);
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
      if (game.hakem == Direction.bottom) {
        showHokmDialog.value = true;
      } else {
        final aiHokm = game.players[game.hakem.index].determineHokm();
        selectHokm(aiHokm);
      }
    }
  }

  /// همگام‌سازی دست بازیکنان با رابط کاربری
  void _syncHandsWithUI() {
    for (var pos in ['bottom', 'right', 'top', 'left']) {
      playerCards[pos]?.clear();
    }
    for (int i = 0; i < 4; i++) {
      final dir = Direction.values[i];
      final pos = _directionToString(dir);
      playerCards[pos]?.addAll(game.hands[i]);
      if (game.players.length == 4) {
        game.players[i].hand.clear();
        game.players[i].hand.addAll(game.hands[i]);
      }
    }
    _sortBottomPlayerCards();
  }

  /// دریافت ترتیب توزیع کارت از یک جهت خاص
  List<Direction> _getDistributionOrder(Direction start) {
    return List.generate(4, (i) => Direction.values[(start.index + i) % 4]);
  }

  /// توزیع مرحله‌ای کارت‌ها به بازیکنان
  Future<void> _dealCardsStepByStep(int numCards) async {
    final order = _getDistributionOrder(game.hakem);
    for (final dir in order) {
      for (int i = 0; i < numCards; i++) {
        final card = game.deck.removeAt(0);
        playSound('pakhsh.mp3');
        final animData =
            AnimatedCard(card: card, targetPosition: _directionToString(dir));
        animatedCards.add(animData);
        update();
        await Future.delayed(const Duration(milliseconds: 350));
        game.hands[dir.index].add(card);
        card.player = game.players.isNotEmpty ? game.players[dir.index] : null;
        playerCards[_directionToString(dir)]?.add(card);
        cards.removeAt(0);
        animatedCards.removeWhere((a) => a.key == animData.key);
        update();
        await Future.delayed(const Duration(milliseconds: 60));
      }
    }
    _syncHandsWithUI();
  }

  /// تبدیل رشته موقعیت به جهت بازیکن
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

  /// انتخاب حکم توسط بازیکن یا هوش مصنوعی
  void selectHokm(Suit suit) async {
    selectedHokm.value = suit;
    showHokmDialog.value = false;
    isGameStarted.value = true;
    game.hokm = suit;
    await _dealCardsStepByStep(4);
    await Future.delayed(const Duration(milliseconds: 300));
    await _dealCardsStepByStep(4);
    _sortBottomPlayerCards();
    currentPlayer.value = hokmPlayer.value;
    isBottomPlayerTurn.value = hokmPlayer.value == 'bottom';
    if (game.hakem != Direction.bottom) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _playComputerCard();
      });
    }
  }

  /// مرتب‌سازی کارت‌های بازیکن پایین
  void _sortBottomPlayerCards() {
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

  /// بازی کردن یک کارت توسط بازیکن یا هوش مصنوعی
  void playCard(GameCard card) {
    if (!canPlayCard(card)) return;
    final dir = Direction.values
        .firstWhere((d) => _directionToString(d) == currentPlayer.value);
    playerCards[currentPlayer.value]
        ?.removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    game.hands[dir.index]
        .removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    if (game.players.length == 4) {
      game.players[dir.index].hand
          .removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    }
    bool isCut = false;
    if (game.table.isNotEmpty) {
      final firstSuit = game.table.first.suit;
      if (card.suit == game.hokm && card.suit != firstSuit) {
        isCut = true;
      }
    }
    if (isCut) {
      playSound('boresh.mp3');
    } else {
      playSound('select.wav');
    }
    final animData = PlayedAnimatedCard(
      card: card,
      fromPosition: currentPlayer.value,
      isCut: isCut,
    );
    animatedPlayedCards.add(animData);
    update();
    final playedBy = currentPlayer.value;
    Future.delayed(const Duration(milliseconds: 350), () {
      tableCards[playedBy] = card;
      animatedPlayedCards.removeWhere((a) => a.key == animData.key);
      update();
    });
    if (game.table.isEmpty) {
      firstSuit.value = card.suit;
    }
    game.playCard(card, dir);
    _syncHandsWithUI();
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

  /// بازی خودکار کارت توسط هوش مصنوعی
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
      starterDirection: game.starterDirection,
    );
    playCard(card);
  }

  /// مدیریت پایان یک دست و بروزرسانی امتیازات
  Future<void> _endHandUI(String winner) async {
    await Future.delayed(const Duration(seconds: 1));
    if (winner == 'bottom' || winner == 'top') {
      teamScores['team1']?.value++;
      team1WonHands.add(1);
    } else {
      teamScores['team2']?.value++;
      team2WonHands.add(1);
    }
    if (teamScores['team1']?.value == 7 || teamScores['team2']?.value == 7) {
      await Future.delayed(const Duration(seconds: 1));
      _endSet();
      return;
    }
    await Future.delayed(const Duration(seconds: 1));
    tableCards.clear();
    firstSuit.value = null;
    currentPlayer.value = winner;
    isBottomPlayerTurn.value = winner == 'bottom';
    if (winner != 'bottom') {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _playComputerCard();
      });
    }
  }

  /// مدیریت پایان یک ست و شروع ست جدید
  void _endSet() {
    String winningTeam;
    if (teamScores['team1']?.value == 7) {
      teamSets['team1']?.value++;
      winningTeam = 'team1';
    } else {
      teamSets['team2']?.value++;
      winningTeam = 'team2';
    }
    teamScores['team1']?.value = 0;
    teamScores['team2']?.value = 0;
    team1WonHands.clear();
    team2WonHands.clear();

    bool hakemTeamWon = (currentHakemDir == Direction.bottom ||
            currentHakemDir == Direction.top)
        ? winningTeam == 'team1'
        : winningTeam == 'team2';
    if (!hakemTeamWon) {
      currentHakemDir = Direction.values[(currentHakemDir!.index + 1) % 4];
    }
    game.hakem = currentHakemDir!;
    hokmPlayer.value = _directionToString(currentHakemDir!);

    if (teamSets['team1']?.value == 7 || teamSets['team2']?.value == 7) {
      _endGame();
      return;
    }
    int secondsLeft = 3;
    Timer? timer;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          timer ??= Timer.periodic(Duration(seconds: 1), (t) {
            if (secondsLeft > 1) {
              setState(() => secondsLeft--);
            } else {
              t.cancel();
              Get.back();
              _initializeCards();
              startGame();
            }
          });
          return AlertDialog(
            title: Text('ست جدید'),
            content: Text(winningTeam == 'team1'
                ? 'شما و یار یک ست بردید!'
                : 'حریفان یک ست بردند!'),
            actions: [
              TextButton(
                onPressed: () {
                  timer?.cancel();
                  Get.back();
                  _initializeCards();
                  startGame();
                },
                child: Text('ادامه ($secondsLeft)'),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  /// مدیریت پایان کامل بازی و نمایش برنده
  void _endGame() {
    final winningTeam = teamSets['team1']?.value == 7 ? 'team1' : 'team2';
    final winningTeamName = winningTeam == 'team1' ? 'شما ' : 'حریف ';
    Get.dialog(
      AlertDialog(
        title: Text('پایان بازی'),
        content: Text('$winningTeamName برنده نهایی شدند!'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text('بستن'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// بررسی امکان بازی کردن کارت توسط بازیکن
  bool canPlayCard(GameCard card) {
    if (!isBottomPlayerTurn.value && currentPlayer.value != 'bottom') {
      return true;
    }
    if (!isBottomPlayerTurn.value) {
      snackMessage(title: 'نوبت شما نیست');
      return false;
    }
    if (tableCards.isEmpty) {
      return true;
    }
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

  /// بررسی فعال بودن کارت برای بازی توسط بازیکن
  bool isCardPlayable(GameCard card) {
    if (!isBottomPlayerTurn.value) {
      return false;
    }
    if (tableCards.isEmpty) {
      return true;
    }
    if (card.suit != firstSuit.value) {
      final hasFirstSuitCard =
          playerCards['bottom']!.any((c) => c.suit == firstSuit.value);
      if (hasFirstSuitCard) {
        return false;
      }
    }
    return true;
  }

  /// نمایش پیام کوتاه به کاربر
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

  /// حذف کارت بالایی از لیست کارت‌ها
  void removeTopCard() {
    if (currentCardIndex.value < cards.length) {
      currentCardIndex.value++;
    }
  }

  /// دریافت نام بازیکن بر اساس موقعیت
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

  /// پاکسازی منابع صوتی هنگام بستن کنترلر
  @override
  void onClose() {
    _isActive = false;
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.onClose();
  }
}
