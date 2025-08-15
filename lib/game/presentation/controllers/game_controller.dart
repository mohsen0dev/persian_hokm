import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:persian_hokm/game/core/game_logic.dart';
import 'package:persian_hokm/game/models/enums.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';
import 'package:persian_hokm/game/presentation/widgets/played_animated_card.dart';
import 'package:persian_hokm/game/core/sound_manager.dart';
import 'package:persian_hokm/game/presentation/utils/ui_helper.dart';
import 'package:persian_hokm/game/core/game_score_manager.dart';
import 'package:persian_hokm/game/core/card_distributor.dart';
import 'package:persian_hokm/game/core/player_team_manager.dart';
import 'package:persian_hokm/game/core/game_state_manager.dart';
import 'package:persian_hokm/game/core/card_manager.dart';
import 'package:persian_hokm/game/core/turn_manager.dart';
import 'package:persian_hokm/game/core/game_utils.dart';
import 'package:persian_hokm/game/presentation/pages/game_screen.dart';

/// کنترلر اصلی بازی حکم
class GameController extends GetxController {
  /// کارت‌های بازی
  final cards = <GameCard>[].obs;

  /// اندیس کارت جاری
  final currentCardIndex = 0.obs;

  /// نمایش تیغه و دایره
  final showTajAndCircle = false.obs;

  /// نمایش کارت‌ها
  final showCards = false.obs;

  /// نمایش دکمه شروع
  final showStartButton = true.obs;

  /// موقعیت کارت‌ها
  final cardPositions = {
    'left': 0.0.obs,
    'right': 0.0.obs,
    'top': 0.0.obs,
  }.obs;

  /// کارت‌های بازیکنان
  final playerCards = {
    'bottom': <GameCard>[].obs,
    'right': <GameCard>[].obs,
    'top': <GameCard>[].obs,
    'left': <GameCard>[].obs,
  }.obs;

  /// بازیکن حاکم
  final Rxn<String> hokmPlayer = Rxn<String>();

  /// توزیع
  final isDistributing = false.obs;

  /// خال حکم
  final selectedHokm = Rxn<Suit>();

  /// نمایش دیالوگ حاکم
  final showHokmDialog = false.obs;

  /// توزیع اول
  final isFirstDistributionDone = false.obs;

  /// توزیع دوم
  final isSecondDistributionDone = false.obs;

  /// توزیع سوم
  final isThirdDistributionDone = false.obs;

  /// بازیکن جاری
  final currentPlayer = ''.obs;

  /// کارت‌های روی میز
  final tableCards = <String, GameCard>{}.obs;

  /// نوبت بازیکن پایین
  final isBottomPlayerTurn = false.obs;

  /// شروع بازی
  final isGameStarted = false.obs;

  /// امتیازات تیم‌ها
  final teamScores = {
    'team1': 0.obs,
    'team2': 0.obs,
  }.obs;

  /// خال اول
  final firstSuit = Rxn<Suit>();

  /// بازی
  late GameLogic game;

  /// انیمیشن کارت‌ها
  final animatedCards = <dynamic>[].obs;

  /// کارت‌های بازی‌شده
  final animatedPlayedCards = <dynamic>[].obs;

  /// تعداد دست‌های برده تیم‌ها
  final teamSets = {
    'team1': 0.obs,
    'team2': 0.obs,
  }.obs;

  /// دست‌های برده تیم 1
  final team1WonHands = <int>[].obs;

  /// دست‌های برده تیم 2
  final team2WonHands = <int>[].obs;
  BuildContext get context => Get.context!;
  final SoundManager soundManager = SoundManager();

  /// جهت حاکم جاری
  Direction? currentHakemDir;

  /// اولین بازی
  bool isFirstGame = true;

  /// فعال بودن بازی
  bool _isActive = true;

  /// مدیر امتیازات
  late final GameScoreManager scoreManager;

  /// توزیع کارت
  late final CardDistributor cardDistributor;

  /// مقداردهی اولیه کنترلر و بازی (اکنون با GameStateManager)
  @override
  void onInit() {
    super.onInit();
    game = GameLogic();
    GameStateManager.initializeGameState(
      playerCards: playerCards,
      teamScores: teamScores,
      teamSets: teamSets,
      hokmPlayer: hokmPlayer,
      showCards: showCards,
      showStartButton: showStartButton,
      showTajAndCircle: showTajAndCircle,
      selectedHokm: selectedHokm,
      showHokmDialog: showHokmDialog,
      isFirstDistributionDone: isFirstDistributionDone,
      isSecondDistributionDone: isSecondDistributionDone,
      isThirdDistributionDone: isThirdDistributionDone,
      cardPositions: cardPositions,
      cards: cards,
      deck: game.deck,
      hands: game.hands,
      animatedPlayedCards: animatedPlayedCards,
      firstSuit: firstSuit,
    );
    scoreManager = GameScoreManager(
      teamScores: teamScores,
      teamSets: teamSets,
      team1WonHands: team1WonHands,
      team2WonHands: team2WonHands,
    );
    cardDistributor = CardDistributor(soundManager: soundManager);

    /// هماهنگ‌سازی فعال بودن صدا با تنظیمات
    final settings = Get.find<SettingsController>();
    soundManager.enabled = settings.soundEnabled.value;
    ever(settings.soundEnabled, (val) {
      soundManager.enabled = val;
    });
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
    showStartButton.value = false;
    showCards.value = true;
    isGameStarted.value = false;
    if (isFirstGame) {
      UIHelper.showSnackBar(context, 'انتخاب حاکم');
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
    UIHelper.showSnackBar(
        context, '${getPlayerName(hokmPlayer.value!)} حاکم شد');
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
      'right': (-50.0).obs,
      'top': (-70.0).obs,
    };
    if (game.players.isEmpty) {
      final aiLevel = Get.find<SettingsController>().aiLevel.value;
      final result = PlayerTeamManager.createPlayersAndTeams(
        aiLevel: aiLevel,
        hands: game.hands,
      );
      game.players = result['players'];
      game.teams = result['teams'];
    }
    await _dealCardsStepByStep(5);
    if (hakemDir == Direction.bottom) {
      showHokmDialog.value = true;
    } else {
      final aiHokm = game.players[hakemDir.index].determineHokm();
      selectHokm(aiHokm);
    }
  }

  /// توزیع کارت برای تعیین حاکم (اکنون با CardDistributor)
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
    String? foundHakem = await cardDistributor.distributeCardsForHakem(
      cards: cards,
      playerCards: playerCards,
      animatedCards: animatedCards,
      isActive: () => _isActive,
      update: update,
      onAceFound: (hakem) async {
        showTajAndCircle.value = true;
        UIHelper.showSnackBar(context, '${getPlayerName(hakem)} حاکم شد');
      },
    );
    if (foundHakem != null) {
      hokmPlayer.value = foundHakem;
      await Future.delayed(
          Duration(milliseconds: (2000 * animationSpeedFactor).toInt()));
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
        'right': (-50.0).obs,
        'top': (-70.0).obs,
      };
      game.hakem = _stringToDirection(hokmPlayer.value ?? '');
      currentHakemDir = game.hakem;
      await _dealCardsStepByStep(5);
      if (game.players.isEmpty) {
        final aiLevel = Get.find<SettingsController>().aiLevel.value;
        final result = PlayerTeamManager.createPlayersAndTeams(
          aiLevel: aiLevel,
          hands: game.hands,
        );
        game.players = result['players'];
        game.teams = result['teams'];
      }
      if (game.hakem == Direction.bottom) {
        showHokmDialog.value = true;
      } else {
        final aiHokm = game.players[game.hakem.index].determineHokm();
        selectHokm(aiHokm);
      }
    }
  }

  /// همگام‌سازی دست بازیکنان با رابط کاربری (اکنون با CardManager)
  void _syncHandsWithUI() {
    CardManager.syncHandsWithUI(
      playerCards: playerCards,
      hands: game.hands,
      players: game.players,
    );
  }

  /// دریافت ترتیب توزیع کارت از یک جهت خاص
  List<Direction> _getDistributionOrder(Direction start) {
    return List.generate(4, (i) => Direction.values[(start.index + i) % 4]);
  }

  /// توزیع مرحله‌ای کارت‌ها به بازیکنان (اکنون با CardDistributor)
  Future<void> _dealCardsStepByStep(int numCards) async {
    final order = _getDistributionOrder(game.hakem);
    await cardDistributor.dealCardsStepByStep(
      numCards: numCards,
      order: order,
      deck: game.deck,
      hands: game.hands,
      players: game.players,
      playerCards: playerCards,
      cards: cards,
      animatedCards: animatedCards,
      update: update,
    );
    _syncHandsWithUI();
  }

  /// تبدیل رشته موقعیت به جهت بازیکن
  Direction _stringToDirection(String pos) {
    return GameUtils.stringToDirection(pos);
  }

  /// تبدیل جهت بازیکن به رشته موقعیت
  String _directionToString(Direction dir) {
    return GameUtils.directionToString(dir);
  }

  /// انتخاب حکم توسط بازیکن یا هوش مصنوعی (کوچک‌سازی شده)
  void selectHokm(Suit suit) async {
    selectedHokm.value = suit;
    showHokmDialog.value = false;
    isGameStarted.value = true;
    game.hokm = suit;
    await _dealCardsStepByStep(4);
    await Future.delayed(
        Duration(milliseconds: (400 * animationSpeedFactor).toInt()));
    await _dealCardsStepByStep(4);
    _sortBottomPlayerCards();
    currentPlayer.value = hokmPlayer.value ?? '';
    isBottomPlayerTurn.value = (hokmPlayer.value ?? '') == 'bottom';
    if (game.hakem != Direction.bottom) {
      Future.delayed(
          Duration(milliseconds: (1000 * animationSpeedFactor).toInt()), () {
        _playComputerCard();
      });
    }
  }

  /// مرتب‌سازی کارت‌های بازیکن پایین (اکنون با CardManager)
  void _sortBottomPlayerCards() {
    CardManager.sortBottomPlayerCards(playerCards: playerCards);
  }

  /// حذف کارت از دست بازیکن (اکنون با CardManager)
  void _removeCardFromPlayer(GameCard card) {
    CardManager.removeCardFromPlayer(
      card: card,
      currentPlayer: currentPlayer.value,
      playerCards: playerCards,
      hands: game.hands,
      players: game.players,
    );
  }

  /// بازی خودکار کارت توسط هوش مصنوعی (کوچک‌سازی شده)
  void _playComputerCard() {
    if (currentPlayer.value == 'bottom') return;
    final dir = Direction.values
        .firstWhere((d) => _directionToString(d) == currentPlayer.value);
    final ai = game.players[dir.index];
    if (game.table.isEmpty) {
      print('\n---------------------------------------------------\n');
    }
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
    await Future.delayed(
        Duration(milliseconds: (1000 * animationSpeedFactor).toInt()));
    tableCards.clear();
    firstSuit.value = null;
    // firstSuit.refresh();
    currentPlayer.value = winner;
    // currentPlayer.refresh();
    isBottomPlayerTurn.value = winner == 'bottom';
    // isBottomPlayerTurn.refresh();
    // update();
    await Future.delayed(
        Duration(milliseconds: (400 * animationSpeedFactor).toInt()));
    scoreManager.increaseHandScore(winner);
    if (scoreManager.isSetFinished()) {
      await Future.delayed(
          Duration(milliseconds: (400 * animationSpeedFactor).toInt()));
      _endSet();
      return;
    }
    await Future.delayed(
        Duration(milliseconds: (100 * animationSpeedFactor).toInt()));
    if (winner != 'bottom') {
      Future.delayed(
          Duration(milliseconds: (100 * animationSpeedFactor).toInt()), () {
        _playComputerCard();
      });
    }
  }

  /// مدیریت پایان یک ست و شروع ست جدید
  void _endSet() {
    // ذخیره امتیازات قبل از پایان ست برای تشخیص نوع برد
    final team1ScoreBefore = teamScores['team1']?.value ?? 0;
    final team2ScoreBefore = teamScores['team2']?.value ?? 0;

    String winningTeam =
        scoreManager.finishSet(currentHakemDir: currentHakemDir!);

    // تشخیص نوع برد
    bool isKod = false;
    bool isHakemKod = false;
    int pointsEarned = 1;

    if (winningTeam == 'team1') {
      if (team2ScoreBefore == 0) {
        isKod = true;
        bool hakemIsTeam1 = (currentHakemDir == Direction.bottom ||
            currentHakemDir == Direction.top);
        if (hakemIsTeam1) {
          final gameScreen = Get.put(GameScreen());
          gameScreen.showWinnerCelebration();
          isHakemKod = true;
          pointsEarned = 3;
        } else {
          pointsEarned = 2;
        }
      }
    } else {
      if (team1ScoreBefore == 0) {
        isKod = true;
        bool hakemIsTeam1 = (currentHakemDir == Direction.bottom ||
            currentHakemDir == Direction.top);
        if (!hakemIsTeam1) {
          isHakemKod = true;
          pointsEarned = 3;
        } else {
          pointsEarned = 2;
        }
      }
    }

    // پاک کردن lastPartnerSuit برای همه بازیکنان در پایان ست
    if (game.players.length == 4) {
      for (final player in game.players) {
        player.lastPartnerSuit = null;
      }
    }
    bool hakemTeamWon = (currentHakemDir == Direction.bottom ||
            currentHakemDir == Direction.top)
        ? winningTeam == 'team1'
        : winningTeam == 'team2';
    if (!hakemTeamWon) {
      currentHakemDir = Direction.values[(currentHakemDir!.index + 1) % 4];
    }
    game.hakem = currentHakemDir!;
    hokmPlayer.value = _directionToString(currentHakemDir!);
    if (scoreManager.isGameFinished()) {
      _endGame();
      return;
    }

    // تغییر: اگر context وجود نداشت (در تست)، فقط ادامه بده
    if (Get.context == null) {
      _initializeCards();
      startGame();
      return;
    }

    // پخش صدای مناسب بر اساس نوع برد
    if (winningTeam == 'team1') {
      if (isHakemKod) {
        soundManager.play('success.mp3'); // برای حاکم کد صدای هیجان‌انگیز
      } else if (isKod) {
        soundManager.play('success.mp3'); // برای کد صدای موفقیت
      } else {
        soundManager.play('success.mp3'); // برای برد معمولی
      }
    } else {
      soundManager.play('lose.mp3'); // برای باخت
    }

    UIHelper.showEndSetDialog(
      context,
      winningTeam,
      isKod,
      isHakemKod,
      pointsEarned,
      () {
        _initializeCards();
        startGame();
      },
    );
  }

  /// مدیریت پایان کامل بازی و نمایش برنده
  void _endGame() {
    // نمایش فشفشه و پخش آهنگ برنده نهایی
    final gameScreen = Get.put(GameScreen());
    gameScreen.showWinnerCelebration();
    final winningTeam = scoreManager.getFinalWinner();
    final Color textColor = winningTeam == 'team1' ? Colors.green : Colors.red;

    String message;
    if (winningTeam == 'team1') {
      message =
          '🎉 شما برنده نهایی شدید! 🎉\n\n🔥 عالی بازی کردید! 🔥\n\n🏆 تبریک! 🏆';
    } else {
      message =
          '😔 حریف برنده نهایی شد! 😔\n\n💪 دفعه بعد بهتر بازی کنید! 💪\n\n😤 ناامید نشوید! 😤';
    }

    // پخش صدای مناسب برنده یا بازنده
    if (winningTeam == 'team1') {
      soundManager.play('success.mp3');
    } else {
      soundManager.play('lose.mp3');
    }

    UIHelper.showEndGameDialog(
      context,
      message,
      textColor,
    );
  }

  /// بررسی امکان بازی کردن کارت توسط بازیکن (اکنون با TurnManager)
  bool canPlayCard(GameCard card) {
    return TurnManager.canPlayCard(
      isBottomPlayerTurn: isBottomPlayerTurn.value,
      currentPlayer: currentPlayer.value,
      tableCards: tableCards,
      firstSuit: firstSuit.value,
      playerCards: playerCards,
      showSnackBar: (msg) => UIHelper.showSnackBar(context, msg),
      card: card,
    );
  }

  /// بررسی فعال بودن کارت برای بازی توسط بازیکن (اکنون با TurnManager)
  bool isCardPlayable(GameCard card) {
    return TurnManager.isCardPlayable(
      isBottomPlayerTurn: isBottomPlayerTurn.value,
      tableCards: tableCards,
      firstSuit: firstSuit.value,
      playerCards: playerCards,
      card: card,
    );
  }

  /// دریافت نام بازیکن بر اساس موقعیت (اکنون با GameUtils)
  String getPlayerName(String position) {
    return GameUtils.getPlayerName(position);
  }

  /// حذف کارت بالایی از لیست کارت‌ها
  void removeTopCard() {
    if (currentCardIndex.value < cards.length) {
      currentCardIndex.value++;
    }
  }

  /// بررسی اینکه آیا کارت بازی‌شده بریده است یا نه
  bool _isCardCutWithTable(GameCard card, List<GameCard> table, Suit hokm) {
    if (table.isEmpty) return false;
    final firstSuit = table.first.suit;
    if (card.suit == hokm && hokm != firstSuit) {
      return true;
    }
    return false;
  }

  /// بازی کردن یک کارت توسط بازیکن یا هوش مصنوعی (کوچک‌سازی شده)
  void playCard(GameCard card) {
    if (!canPlayCard(card)) return;
    final dir = Direction.values
        .firstWhere((d) => _directionToString(d) == currentPlayer.value);
    final tableBefore = List<GameCard>.from(game.table);
    _removeCardFromPlayer(card);
    // CardManager.removeCardFromPlayer(
    //   card: card,
    //   currentPlayer: currentPlayer.value,
    //   playerCards: playerCards,
    //   hands: game.hands,
    //   players: game.players,
    // );
    if (game.table.isEmpty) {
      firstSuit.value = card.suit;
    }
    game.playCard(card, dir);
    _syncHandsWithUI();
    playerCards['bottom'];
    bool isCut = _isCardCutWithTable(card, tableBefore, game.hokm);
    soundManager.play(isCut ? 'boresh.mp3' : 'select.mp3');
    final animData = PlayedAnimatedCard(
      card: card,
      fromPosition: currentPlayer.value,
      isCut: isCut,
    );
    animatedPlayedCards.add(animData);
    final playedBy = currentPlayer.value;
    Future.delayed(Duration(milliseconds: (400 * animationSpeedFactor).toInt()),
        () {
      tableCards[playedBy] = card;
      animatedPlayedCards.removeWhere((a) => a.key == animData.key);
    });
    if (game.table.isEmpty) {
      final winner = _directionToString(game.tableDir);
      _endHandUI(winner);
    } else {
      currentPlayer.value = _directionToString(game.tableDir);
      isBottomPlayerTurn.value = currentPlayer.value == 'bottom';
      if (currentPlayer.value != 'bottom') {
        Future.delayed(
            Duration(milliseconds: (1000 * animationSpeedFactor).toInt()), () {
          _playComputerCard();
        });
      }
    }
  }

  /// پاکسازی منابع صوتی هنگام بستن کنترلر
  @override
  void onClose() {
    _isActive = false;
    soundManager.dispose();
    super.onClose();
  }

  double get animationSpeedFactor {
    final speed = Get.find<SettingsController>().animationSpeed.value;
    if (speed == 0) return 2; // آهسته
    if (speed == 2) return 0.5; // تند
    return 1.0; // عادی
  }

  /// آیا در مرحله توزیع کارت برای تعیین حاکم هستیم؟
  bool get isDistributingForHakem => hokmPlayer.value != '';

  /// واگذاری ست توسط بازیکن
  void giveUpSet() {
    // ریست کردن وضعیت بازی قبل از واگذاری ست
    tableCards.clear();
    animatedPlayedCards.clear();
    isBottomPlayerTurn.value = false;
    animatedPlayedCards.clear;
    game.table.clear();
    // واگذاری ست
    _endSet();
  }
}
