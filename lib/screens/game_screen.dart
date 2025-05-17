import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/models/card.dart';
import 'package:persian_hokm/widgets/card_widget.dart';

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

  @override
  void onInit() {
    super.onInit();
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
    for (var position in cardPositions.values) {
      position.value = 0;
    }

    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        cards.add(GameCard(suit: suit, rank: rank));
      }
    }
    cards.shuffle(Random());
  }

  /// شروع بازی
  void startGame() {
    print('Starting game...');
    showStartButton.value = false;
    showCards.value = true;
    isGameStarted.value = false;
    currentPlayer.value = hokmPlayer.value;
    isBottomPlayerTurn.value = hokmPlayer.value == 'bottom';
    print(
        'Game started. Current player: ${currentPlayer.value}, Is bottom turn: ${isBottomPlayerTurn.value}');
    _distributeCards();
  }

  /// توزیع کارت ها به بازیکنان
  Future<void> _distributeCards() async {
    isDistributing.value = true;
    final distributionOrder = ['bottom', 'right', 'top', 'left'];
    int currentPlayerIndex = 0;

    while (currentCardIndex.value < cards.length) {
      final currentCard = cards[currentCardIndex.value];
      final currentPlayer = distributionOrder[currentPlayerIndex];

      // Add card to player's hand
      playerCards[currentPlayer]?.add(currentCard);

      // Check for Ace
      if (currentCard.rank == Rank.ace) {
        hokmPlayer.value = currentPlayer;
        showTajAndCircle.value = true;

        // Show snackbar with hokm player name
        Get.snackbar(
          'حاکم مشخص شد!',
          '${getPlayerName(currentPlayer)} حاکم شد',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Wait for snackbar to be visible
        await Future.delayed(const Duration(seconds: 2));

        // Collect all cards and redistribute
        await _collectAndRedistributeCards();

        break;
      }

      currentCardIndex.value++;
      currentPlayerIndex = (currentPlayerIndex + 1) % 4;

      // Wait for animation
      await Future.delayed(const Duration(milliseconds: 500));
    }

    isDistributing.value = false;
  }

  /// جمع کردن کارت ها و توزیع مجدد
  Future<void> _collectAndRedistributeCards() async {
    // Clear all player cards
    for (var playerCards in playerCards.values) {
      playerCards.clear();
    }

    // Reset current card index
    currentCardIndex.value = 0;

    // Shuffle cards again
    cards.shuffle(Random());

    cardPositions.value = {
      'left': (-50.0).obs,
      'right': (-50.0).obs,
      'top': (-60.0).obs,
    };

    // Get distribution order based on hokm player
    final distributionOrder = _getDistributionOrder();

    // Distribute first 5 cards to each player
    for (String position in distributionOrder) {
      for (int i = 0; i < 5; i++) {
        if (currentCardIndex.value < cards.length) {
          playerCards[position]?.add(cards[currentCardIndex.value]);
          currentCardIndex.value++;
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Sort bottom player's cards
    _sortBottomPlayerCards();

    isFirstDistributionDone.value = true;

    // Show hokm dialog only for bottom player
    if (hokmPlayer.value == 'bottom') {
      showHokmDialog.value = true;
    } else {
      // For other players, select random hokm
      selectRandomHokm();
    }
  }

  /// توزیع کارت‌های مرحله دوم
  Future<void> distributeSecondRound() async {
    final distributionOrder = _getDistributionOrder();

    // Distribute 4 cards to each player
    for (String position in distributionOrder) {
      for (int i = 0; i < 4; i++) {
        if (currentCardIndex.value < cards.length) {
          playerCards[position]?.add(cards[currentCardIndex.value]);
          currentCardIndex.value++;
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Sort bottom player's cards
    _sortBottomPlayerCards();

    isSecondDistributionDone.value = true;
    distributeThirdRound();
  }

  /// توزیع کارت‌های مرحله سوم
  Future<void> distributeThirdRound() async {
    final distributionOrder = _getDistributionOrder();

    // Distribute 4 cards to each player
    for (String position in distributionOrder) {
      for (int i = 0; i < 4; i++) {
        if (currentCardIndex.value < cards.length) {
          playerCards[position]?.add(cards[currentCardIndex.value]);
          currentCardIndex.value++;
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Sort bottom player's cards
    _sortBottomPlayerCards();

    isThirdDistributionDone.value = true;

    // اگر حاکم کامپیوتر است، کارت بازی کند
    if (hokmPlayer.value != 'bottom') {
      Future.delayed(Duration(milliseconds: 1000), () {
        _playComputerCard();
      });
    }
  }

  /// مرتب کردن کارت‌های بازیکن پایین
  void _sortBottomPlayerCards() {
    if (playerCards['bottom']?.isNotEmpty ?? false) {
      playerCards['bottom']?.sort((a, b) {
        // Custom suit order: Hearts (0), Clubs (1), Diamonds (2), Spades (3)
        final suitOrder = {
          Suit.hearts: 0,
          Suit.clubs: 1,
          Suit.diamonds: 2,
          Suit.spades: 3,
        };

        if (a.suit != b.suit) {
          return suitOrder[a.suit]!.compareTo(suitOrder[b.suit]!);
        }
        return b.rank.index.compareTo(a.rank.index); // Descending order
      });
    }
  }

  /// دریافت ترتیب تقسیم کارت بر اساس حاکم
  List<String> _getDistributionOrder() {
    switch (hokmPlayer.value) {
      case 'bottom':
        return ['bottom', 'right', 'top', 'left'];
      case 'right':
        return ['right', 'top', 'left', 'bottom'];
      case 'top':
        return ['top', 'left', 'bottom', 'right'];
      case 'left':
        return ['left', 'bottom', 'right', 'top'];
      default:
        return ['bottom', 'right', 'top', 'left'];
    }
  }

  /// انتخاب خال حکم
  void selectHokm(Suit suit) {
    print('Hokm selected: ${suit.toString()}');
    selectedHokm.value = suit;
    showHokmDialog.value = false;
    isGameStarted.value = true;
    currentPlayer.value = hokmPlayer.value;
    isBottomPlayerTurn.value = hokmPlayer.value == 'bottom';
    print(
        'Game started after hokm selection. Current player: ${currentPlayer.value}, Is bottom turn: ${isBottomPlayerTurn.value}');
    distributeSecondRound();
  }

  /// انتخاب خودکار حکم برای کامپیوتر
  void selectRandomHokm() {
    final suits = Suit.values;
    selectedHokm.value = suits[Random().nextInt(suits.length)];
    print('Random hokm selected: ${selectedHokm.value}');
    isGameStarted.value = true;
    currentPlayer.value = hokmPlayer.value;
    isBottomPlayerTurn.value = hokmPlayer.value == 'bottom';
    print(
        'Game started after random hokm selection. Current player: ${currentPlayer.value}, Is bottom turn: ${isBottomPlayerTurn.value}');
    distributeSecondRound();
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

  /// بررسی امکان بازی کارت
  bool canPlayCard(GameCard card) {
    // اگر نوبت بازیکن پایین نیست و بازیکن پایین نیست، اجازه بازی بده
    if (!isBottomPlayerTurn.value && currentPlayer.value != 'bottom') {
      return true;
    }

    // اگر نوبت بازیکن پایین نیست، اجازه بازی نده
    if (!isBottomPlayerTurn.value) {
      print('Not bottom player turn');
      return false;
    }

    if (tableCards.isEmpty) {
      print('First card of the hand');
      return true;
    }

    // اگر کارت از خال اول دست نباشد و بازیکن کارت از خال اول دست داشته باشد، نمی‌تواند کارت دیگری بازی کند
    if (card.suit != firstSuit.value) {
      final hasFirstSuitCard =
          playerCards['bottom']!.any((c) => c.suit == firstSuit.value);
      if (hasFirstSuitCard) {
        print('Player has first suit card but trying to play different suit');
        return false;
      }
    }

    print('Card can be played');
    return true;
  }

  /// بازی کردن کارت
  void playCard(GameCard card) {
    print('Playing card: ${card.toString()}');
    if (!canPlayCard(card)) {
      print('Cannot play card');
      return;
    }

    // اضافه کردن کارت به میز
    tableCards[currentPlayer.value] = card;
    print('Card added to table');

    // حذف کارت از دست بازیکن
    final playerCardsList = playerCards[currentPlayer.value]!;
    final index = playerCardsList
        .indexWhere((c) => c.suit == card.suit && c.rank == card.rank);
    if (index != -1) {
      playerCardsList.removeAt(index);
    }
    print('Card removed from player hand');

    // تنظیم خال اول دست
    if (tableCards.length == 1) {
      firstSuit.value = card.suit;
      print('First suit set to: ${card.suit}');
    }

    // تغییر نوبت به بازیکن بعدی
    _nextPlayer();
    print('Turn changed to: ${currentPlayer.value}');

    // به‌روزرسانی UI
    update();

    // اگر همه بازیکنان کارت بازی کرده‌اند، دست را تمام کن
    if (tableCards.length == 4) {
      print('Hand complete, ending hand');
      _endHand();
    } else {
      // اگر نوبت بازیکن کامپیوتر است، کارت بازی کن
      if (currentPlayer.value != 'bottom') {
        print('Computer player turn, playing computer card');
        Future.delayed(Duration(milliseconds: 1000), () {
          _playComputerCard();
        });
      }
    }
  }

  /// بازی کردن کارت توسط کامپیوتر
  void _playComputerCard() {
    print('_playComputerCard called for player: ${currentPlayer.value}');
    if (currentPlayer.value == 'bottom') {
      print('Current player is bottom, returning');
      return;
    }

    final computerCards = playerCards[currentPlayer.value]!;
    if (computerCards.isEmpty) {
      print('Computer has no cards, returning');
      return;
    }

    print('Computer cards: ${computerCards.length}');
    GameCard? selectedCard;

    // اگر اولین کارت دست است
    if (tableCards.isEmpty) {
      print('First card of the hand');
      // اگر کارت حکم دارد، آن را بازی کن
      selectedCard = computerCards.firstWhere(
        (card) => card.suit == selectedHokm.value,
        orElse: () => computerCards.first,
      );
    } else {
      print('Not first card, first suit: ${firstSuit.value}');
      // اگر کارت از خال اول دست دارد، آن را بازی کن
      final firstSuitCards =
          computerCards.where((card) => card.suit == firstSuit.value).toList();
      if (firstSuitCards.isNotEmpty) {
        print('Playing first suit card');
        selectedCard = firstSuitCards.first;
      } else {
        print('No first suit card, checking for hokm');
        // اگر کارت حکم دارد، آن را بازی کن
        final hokmCards = computerCards
            .where((card) => card.suit == selectedHokm.value)
            .toList();
        if (hokmCards.isNotEmpty) {
          print('Playing hokm card');
          selectedCard = hokmCards.first;
        } else {
          print('Playing random card');
          selectedCard = computerCards.first;
        }
      }
    }

    if (selectedCard != null) {
      print('Selected card: ${selectedCard.toString()}');
      playCard(selectedCard);
    } else {
      print('No card selected');
    }
  }

  /// تغییر نوبت به بازیکن بعدی
  void _nextPlayer() {
    final players = ['bottom', 'right', 'top', 'left'];
    final currentIndex = players.indexOf(currentPlayer.value);
    final nextIndex = (currentIndex + 1) % 4;
    currentPlayer.value = players[nextIndex];
    isBottomPlayerTurn.value = currentPlayer.value == 'bottom';
    print(
        'Turn changed to: ${currentPlayer.value}, Is bottom turn: ${isBottomPlayerTurn.value}');
  }

  /// پایان دست و محاسبه امتیاز
  void _endHand() async {
    print('Ending hand...');
    // محاسبه برنده دست
    final winner = _calculateHandWinner();
    print('Hand winner: $winner');

    // اضافه کردن امتیاز به تیم برنده
    if (winner == 'bottom' || winner == 'top') {
      teamScores['team1']?.value++;
      print('Team 1 scored. New score: ${teamScores['team1']?.value}');
    } else {
      teamScores['team2']?.value++;
      print('Team 2 scored. New score: ${teamScores['team2']?.value}');
    }

    // بررسی برنده بازی
    if (teamScores['team1']?.value == 7 || teamScores['team2']?.value == 7) {
      _endGame();
      return;
    }

    // تاخیر برای نمایش کارت‌ها
    await Future.delayed(Duration(seconds: 2));

    // پاک کردن کارت‌های روی میز
    tableCards.clear();
    firstSuit.value = null;
    print('Table cleared');

    // شروع دست جدید با بازیکن برنده
    currentPlayer.value = winner;
    isBottomPlayerTurn.value = winner == 'bottom';
    print(
        'New hand started. Current player: ${currentPlayer.value}, Is bottom turn: ${isBottomPlayerTurn.value}');

    // اگر برنده کامپیوتر است، کارت بازی کند
    if (winner != 'bottom') {
      Future.delayed(Duration(milliseconds: 1000), () {
        _playComputerCard();
      });
    }
  }

  /// پایان بازی
  void _endGame() {
    final winningTeam = teamScores['team1']?.value == 7 ? 'team1' : 'team2';
    final winningTeamName = winningTeam == 'team1' ? 'شما و یار' : 'حریفان';

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

  /// محاسبه برنده دست
  String _calculateHandWinner() {
    String winner = tableCards.keys.first;
    GameCard? winningCard = tableCards[winner];

    for (var entry in tableCards.entries) {
      final card = entry.value;
      if (_isCardHigher(card, winningCard!)) {
        winningCard = card;
        winner = entry.key;
      }
    }

    return winner;
  }

  /// بررسی اینکه آیا کارت اول از کارت دوم قوی‌تر است
  bool _isCardHigher(GameCard card1, GameCard card2) {
    // اگر کارت اول حکم است و کارت دوم حکم نیست
    if (card1.suit == selectedHokm.value && card2.suit != selectedHokm.value) {
      return true;
    }
    // اگر کارت دوم حکم است و کارت اول حکم نیست
    if (card2.suit == selectedHokm.value && card1.suit != selectedHokm.value) {
      return false;
    }
    // اگر هر دو کارت حکم هستند یا هر دو حکم نیستند
    if (card1.suit == card2.suit) {
      return card1.rank.index > card2.rank.index;
    }
    // اگر کارت اول از خال اول دست است و کارت دوم نیست
    if (card1.suit == firstSuit.value && card2.suit != firstSuit.value) {
      return true;
    }
    return false;
  }
}

class GameScreen extends StatelessWidget {
  GameScreen({super.key});

  final controller = Get.put(GameController());

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
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
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
      ),
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
              : Container(
                  // color: Colors.amber,
                  height: 150,
                  width: 250,
                  child: Stack(
                    // fit: StackFit.passthrough,
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
                                      // right: entry.key == 'right' ? 10 : null,
                                      // left: entry.key == 'left' ? 10 : null,
                                      // top: entry.key == 'top' ? 10 : null,
                                      // bottom: entry.key == 'bottom' ? 10 : null,
                                      child: CardWidget(
                                        card: entry.value,
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : SizedBox()),
                      // نمایش کارت‌های پشته در حالت اولیه
                      if (controller.showCards.value)
                        for (int i = controller.cards.length - 1;
                            i >= controller.currentCardIndex.value;
                            i--)
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
                                          print(
                                              'Card tapped: ${card.toString()}');
                                          print(
                                              'Is bottom player turn: ${controller.isBottomPlayerTurn.value}');
                                          print(
                                              'Can play card: ${controller.canPlayCard(card)}');
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
                            height: 230,
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
                                            0.2),
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
                          height: 230,
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
                                          0.2),
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
