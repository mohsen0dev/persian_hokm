import 'package:flutter/material.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'dart:math';
import 'card_widget.dart';

class PlayedAnimatedCard extends StatelessWidget {
  final GameCard card;
  final String fromPosition; // 'bottom', 'right', 'top', 'left'
  final bool isCut;
  final VoidCallback? onAnimationEnd;
  final Key? animationKey;

  const PlayedAnimatedCard({
    required this.card,
    required this.fromPosition,
    this.isCut = false,
    this.onAnimationEnd,
    this.animationKey,
    super.key,
  });

  Alignment _getStartAlignment() {
    switch (fromPosition) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      case 'top':
        return Alignment.topCenter;
      case 'bottom':
      default:
        return Alignment.bottomCenter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      onEnd: onAnimationEnd,
      builder: (context, value, child) {
        final alignment =
            Alignment.lerp(_getStartAlignment(), Alignment.center, value)!;

        double scale = 1.0;
        double rotation = 0.0;
        double glowOpacity = 0.0;

        if (isCut) {
          if (value < 0.5) {
            scale = 1.0 + (value * 0.8);
          } else {
            scale = 1.0 + ((1 - value) * 0.8);
          }

          if (value > 0.2 && value < 0.8) {
            rotation = sin((value - 0.2) / 0.6 * 8 * pi) * 0.2;
          }

          if (value < 0.5) {
            glowOpacity = value * 2;
          } else {
            glowOpacity = (1 - value) * 2;
          }
        }

        return Align(
          alignment: alignment,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Container(
                decoration: isCut
                    ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withOpacity(glowOpacity),
                            blurRadius: 50.0 * glowOpacity,
                            spreadRadius: 20.0 * glowOpacity,
                          ),
                        ],
                      )
                    : null,
                child: child,
              ),
            ),
          ),
        );
      },
      child: CardWidget(card: card),
    );
  }
}
