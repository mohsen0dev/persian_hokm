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
  final Rxn<String> hokmPlayer = Rxn<String>();
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
  final SoundManager soundManager = SoundManager();
  Direction? currentHakemDir;
  bool isFirstGame = true;
  bool _isActive = true;
  late final GameScoreManager scoreManager;
  late final CardDistributor cardDistributor;

  // اضافه کردن واکنش به تغییر isBottomPlayerTurn
  // GameController() {
  //   ever(isBottomPlayerTurn, (bool turn) {
  //     if (turn == true) {
  //       print('بازیکن پاییین نوبتش استتتتتتتتتتتتتتتتت');
  //       update();
  //     }
  //   });
  // }

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
    UIHelper.showSnackBar(context, 'انتخاب حاکم');
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
      'right': (-90.0).obs,
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
      onAceFound: () async {
        showTajAndCircle.value = true;
        UIHelper.showSnackBar(
            context, '${getPlayerName(hokmPlayer.value!)} حاکم شد');
      },
    );
    if (foundHakem != null) {
      hokmPlayer.value = foundHakem;
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
        'right': (-90.0).obs,
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
    await Future.delayed(const Duration(milliseconds: 300));
    await _dealCardsStepByStep(4);
    _sortBottomPlayerCards();
    currentPlayer.value = hokmPlayer.value ?? '';
    isBottomPlayerTurn.value = (hokmPlayer.value ?? '') == 'bottom';
    if (game.hakem != Direction.bottom) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _playComputerCard();
      });
    }
  }

  /// مرتب‌سازی کارت‌های بازیکن پایین (اکنون با CardManager)
  void _sortBottomPlayerCards() {
    CardManager.sortBottomPlayerCards(playerCards: playerCards);
  }

  /// حذف کارت از دست بازیکن (اکنون با CardManager)
  void _removeCardFromPlayer(GameCard card, Direction dir) {
    CardManager.removeCardFromPlayer(
      card: card,
      currentPlayer: currentPlayer.value,
      playerCards: playerCards,
      hands: game.hands,
      players: game.players,
    );
  }

  /// بررسی برش کارت (متد کمکی)
  bool _isCardCut(GameCard card) {
    if (game.table.isNotEmpty) {
      final firstSuit = game.table.first.suit;
      if (card.suit == game.hokm && card.suit != firstSuit) {
        return true;
      }
    }
    return false;
  }

  /// بازی خودکار کارت توسط هوش مصنوعی (کوچک‌سازی شده)
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
    await Future.delayed(const Duration(milliseconds: 1000));
    tableCards.clear();
    firstSuit.value = null;
    // firstSuit.refresh();
    currentPlayer.value = winner;
    // currentPlayer.refresh();
    isBottomPlayerTurn.value = winner == 'bottom';
    // isBottomPlayerTurn.refresh();
    // update();
    await Future.delayed(const Duration(milliseconds: 1000));
    scoreManager.increaseHandScore(winner);
    if (scoreManager.isSetFinished()) {
      await Future.delayed(const Duration(milliseconds: 1000));
      _endSet();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    if (winner != 'bottom') {
      Future.delayed(const Duration(milliseconds: 300), () {
        _playComputerCard();
      });
    }
  }

  /// مدیریت پایان یک ست و شروع ست جدید
  void _endSet() {
    String winningTeam = scoreManager.finishSet();
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
    UIHelper.showEndSetDialog(
      context,
      winningTeam == 'team1'
          ? 'شما و یار این ست را بردید!'
          : 'حریفان این ست را بردند!',
      () {
        _initializeCards();
        startGame();
      },
    );
  }

  /// مدیریت پایان کامل بازی و نمایش برنده
  void _endGame() {
    final winningTeam = scoreManager.getFinalWinner();
    final winningTeamName = winningTeam == 'team1' ? 'شما ' : 'حریف ';
    UIHelper.showEndGameDialog(context, '$winningTeamName برنده نهایی شدند!');
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

  /// بازی کردن یک کارت توسط بازیکن یا هوش مصنوعی (کوچک‌سازی شده)
  void playCard(GameCard card) {
    if (!canPlayCard(card)) return;
    final dir = Direction.values
        .firstWhere((d) => _directionToString(d) == currentPlayer.value);
    CardManager.removeCardFromPlayer(
      card: card,
      currentPlayer: currentPlayer.value,
      playerCards: playerCards,
      hands: game.hands,
      players: game.players,
    );
    if (game.table.isEmpty) {
      firstSuit.value = card.suit;
    }
    game.playCard(card, dir);
    _syncHandsWithUI();
    // ریفرش کارت‌های پایین برای آپدیت صحیح UI
    playerCards['bottom']?.refresh();
    bool isCut = _isCardCut(card);
    soundManager.play(isCut ? 'boresh.mp3' : 'select.wav');
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
      final winner = _directionToString(game.tableDir);
      _endHandUI(winner);
    } else {
      currentPlayer.value = _directionToString(game.tableDir);
      isBottomPlayerTurn.value = currentPlayer.value == 'bottom';
      update();
      if (currentPlayer.value != 'bottom') {
        Future.delayed(const Duration(milliseconds: 1000), () {
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
}
