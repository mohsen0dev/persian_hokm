import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/models/card.dart';

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

  @override
  void onInit() {
    super.onInit();
    _initializeCards();
  }

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

  void startGame() {
    showStartButton.value = false;
    showCards.value = true;
    _distributeCards();
  }

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
        break;
      }

      currentCardIndex.value++;
      currentPlayerIndex = (currentPlayerIndex + 1) % 4;

      // Wait for animation
      await Future.delayed(const Duration(milliseconds: 500));
    }

    isDistributing.value = false;
  }

  void removeTopCard() {
    if (currentCardIndex.value < cards.length) {
      currentCardIndex.value++;
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
        backgroundColor: Colors.blueAccent,
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
              right: 0,
              top: 0,
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
          Text('شما: 0'),
          Row(
            children: [
              Text(
                'حکم ',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Image.asset(
                'assets/drawables/clubs.png',
                width: 25,
              ),
            ],
          ),
          Text('حریف: 0'),
        ],
      ),
    );
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
                  onTap: controller.removeTopCard,
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
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Obx(
        () => Column(
          children: [
            if (controller.hokmPlayer.value == 'bottom')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [...tajAnCir()],
              ),
            SizedBox(height: 4),
            Center(
              child: Obx(
                () => controller.playerCards['bottom']?.isNotEmpty ?? false
                    ? CardWidget(
                        card: controller.playerCards['bottom']!.last,
                      )
                    : SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardLeft() {
    return Obx(
      () => Positioned(
        left: controller.cardPositions['left']?.value ?? 0,
        bottom: 0,
        top: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.hokmPlayer.value == 'left')
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [...tajAnCir()],
              ),
            Center(
              child: Obx(
                () => controller.playerCards['left']?.isNotEmpty ?? false
                    ? CardWidget(
                        card: controller.playerCards['left']!.last,
                      )
                    : SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardRight() {
    return Obx(
      () => Positioned(
        right: controller.cardPositions['right']?.value ?? 0,
        bottom: 0,
        top: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Obx(
                () => controller.playerCards['right']?.isNotEmpty ?? false
                    ? CardWidget(
                        card: controller.playerCards['right']!.last,
                      )
                    : SizedBox(),
              ),
            ),
            if (controller.hokmPlayer.value == 'right')
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [...tajAnCir()],
              ),
          ],
        ),
      ),
    );
  }

  Widget cardTop() {
    return Obx(
      () => Positioned(
        top: controller.cardPositions['top']?.value ?? 0,
        left: 0,
        right: 0,
        child: Column(
          children: [
            Center(
              child: Obx(
                () => controller.playerCards['top']?.isNotEmpty ?? false
                    ? CardWidget(
                        card: controller.playerCards['top']!.last,
                      )
                    : SizedBox(),
              ),
            ),
            if (controller.hokmPlayer.value == 'top')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [...tajAnCir()],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> tajAnCir() {
    return [
      Image.asset(
        'assets/drawables/taj.png',
        height: 20,
      ),
      Container(
        margin: EdgeInsets.all(8),
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
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
