import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/models/card.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

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
            cardBotton(),
            cardLeft(),
            cardRight(),
            cardTop(),
            Platform.isWindows
                ? Positioned(
                    right: 0, top: 0, child: CircleAvatar(child: CloseButton()))
                : SizedBox(),
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
                // height: 30,
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
        child: Stack(
          children: [
            CardWidget(
              card: GameCard(suit: Suit.hearts, rank: Rank.ace),
            ),
            Positioned.fill(
              child: Image.asset(
                'assets/images/card_back_black.png',
                width: 100,
                height: 150,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardBotton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Image.asset(
            'assets/drawables/taj.png',
            height: 20,
            // height: 30,
          ),
          SizedBox(
            height: 4,
          ),
          Center(
            child: CardWidget(
              card: GameCard(suit: Suit.hearts, rank: Rank.ace),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardLeft() {
    return Positioned(
      left: -50,
      bottom: 0,
      top: 0,
      child: Center(
        child: CardWidget(
          card: GameCard(suit: Suit.hearts, rank: Rank.ace),
        ),
      ),
    );
  }

  Widget cardRight() {
    return Positioned(
      right: -50,
      bottom: 0,
      top: 0,
      child: Center(
        child: CardWidget(
          card: GameCard(suit: Suit.clubs, rank: Rank.eight),
        ),
      ),
    );
  }

  Widget cardTop() {
    return Positioned(
      top: -85,
      left: 0,
      right: 0,
      child: Center(
        child: CardWidget(
          card: GameCard(suit: Suit.hearts, rank: Rank.ace),
        ),
      ),
    );
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
            blurRadius: 5,
            offset: const Offset(0, 3),
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
