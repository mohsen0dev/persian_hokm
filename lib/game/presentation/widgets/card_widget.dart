import 'package:flutter/material.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';

class CardWidget extends StatelessWidget {
  final GameCard card;
  final bool isSelectable;
  final Color borderColor;
  final bool showBack;

  const CardWidget({
    super.key,
    required this.card,
    this.isSelectable = false,
    this.borderColor = Colors.green,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showBack) {
      final settingsController = Get.find<SettingsController>();
      final idx = settingsController.cardBackIndex.value;
      final isColor = idx < settingsController.cardBackColors.length;
      return Container(
        width: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isSelectable ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: isColor
              ? Container(
                  width: 70,
                  height: 100,
                  color: settingsController.cardBackColors[idx],
                )
              : Image.asset(
                  settingsController.cardBackImages[
                      idx - settingsController.cardBackColors.length],
                  fit: BoxFit.cover,
                  width: 70,
                  height: 100,
                ),
        ),
      );
    }
    return Container(
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: isSelectable ? 2 : 1,
        ),
        color: isSelectable ? const Color(0xFF232526).withOpacity(0.92) : null,
        boxShadow: isSelectable
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(3, 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.asset(
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
            if (isSelectable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
