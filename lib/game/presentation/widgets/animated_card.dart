import 'package:flutter/material.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'card_widget.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';

/// ویجت کارت متحرک برای انیمیشن انتقال کارت از مرکز به موقعیت بازیکن
class AnimatedCard extends StatefulWidget {
  final GameCard card;
  final String targetPosition; // 'bottom', 'right', 'top', 'left'
  final VoidCallback? onAnimationEnd;
  final Key? animationKey;
  final bool showBack;

  const AnimatedCard({
    required this.card,
    required this.targetPosition,
    this.onAnimationEnd,
    this.animationKey,
    this.showBack = true,
    super.key,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  late Alignment beginAlignment;
  late Alignment endAlignment;

  @override
  void initState() {
    super.initState();
    beginAlignment = Alignment.center;
    endAlignment = _getTargetAlignment(widget.targetPosition);
    // اجرای callback بعد از انیمیشن
    final speed = Get.find<SettingsController>().animationSpeed.value;
    double factor = 1.0;
    if (speed == 0) factor = 1.7;
    if (speed == 2) factor = 0.5;
    final delay = Duration(milliseconds: (600 * factor).toInt());
    Future.delayed(delay, () {
      if (widget.onAnimationEnd != null) widget.onAnimationEnd!();
    });
  }

  Alignment _getTargetAlignment(String pos) {
    switch (pos) {
      case 'bottom':
        return Alignment.bottomCenter;
      case 'top':
        return Alignment.topCenter;
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final speed = Get.find<SettingsController>().animationSpeed.value;
    double factor = 1.0;
    if (speed == 0) factor = 1.7;
    if (speed == 2) factor = 0.5;
    final duration = Duration(milliseconds: (350 * factor).toInt());
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, animValue, child) {
        final alignment =
            Alignment.lerp(beginAlignment, endAlignment, animValue)!;
        final rotation = animValue * 2 * 3.1415926535 * 2; // 2 دور کامل
        return Align(
          alignment: alignment,
          child: Transform.rotate(
            angle: rotation,
            child: child,
          ),
        );
      },
      child: CardWidget(card: widget.card, showBack: widget.showBack),
    );
  }
}
