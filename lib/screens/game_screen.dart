import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/models/card.dart';

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
    showStartButton.value = false;
    showCards.value = true;
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

    // Sort bottom player's cards by suit and rank
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

    // Distribute 13 cards to each player
    for (int i = 0; i < 13; i++) {
      for (String position in ['bottom', 'right', 'top', 'left']) {
        if (currentCardIndex.value < cards.length) {
          playerCards[position]?.add(cards[currentCardIndex.value]);
          currentCardIndex.value++;
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    }
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
        // backgroundColor: Colors.blueAccent,
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
                Text('شما: 0'),
                Text('حریف: 0'),
              ],
            ),
          ),
          bkgText(
            child: Column(
              children: [
                Text(
                  'حکم ',
                  style: TextStyle(
                      // fontSize: 16,
                      ),
                ),
                Image.asset(
                  'assets/drawables/clubs.png',
                  width: 20,
                ),
              ],
            ),
          ),
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
              : GestureDetector(
                  // onTap: controller.removeTopCard,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
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
                                      child: CardWidget(
                                        card: controller
                                            .playerCards['bottom']![i],
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
}

class CardWidget extends StatelessWidget {
  final GameCard card;

  const CardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).height * 0.15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 1,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          card.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  '${card.rankName}\n${card.suitSymbol}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
