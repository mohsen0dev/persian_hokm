import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/presentation/controllers/game_controller.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';
import 'package:persian_hokm/game/presentation/widgets/animated_card.dart';
import 'package:persian_hokm/game/presentation/widgets/card_widget.dart';
import 'package:persian_hokm/game/presentation/widgets/played_animated_card.dart';
import 'package:persian_hokm/game/presentation/widgets/screen_size_guard.dart';
import 'dart:math' as math;

class GameScreen extends StatelessWidget {
  /// کنترلر اصلی بازی که منطق و وضعیت بازی را مدیریت می‌کند.
  final controller = Get.put(GameController());

  /// کنترلر تنظیمات برای دسترسی به تنظیمات پس‌زمینه و غیره.
  final settingsController = Get.put(SettingsController());

  GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
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
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
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
      child: Obx(() {
        final idx = settingsController.backgroundIndex.value;
        final isColor = idx < settingsController.backgroundColors.length;
        return ScreenSizeGuard(
          child: Scaffold(
            body: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                isColor
                    ? Container(color: settingsController.backgroundColors[idx])
                    : RotatedBox(
                        quarterTurns: isLandscape ? 0 : 1,
                        child: Container(
                          margin: EdgeInsets.all(30),

                          // padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  settingsController.backgroundImages[idx -
                                      settingsController
                                          .backgroundColors.length]),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                textTop(context),
                cardCenter(isLandscape),
                Obx(() => controller.showCards.value
                    ? Container(child: cardBotton(context))
                    : SizedBox()),
                Obx(() => controller.showCards.value ? cardLeft() : SizedBox()),
                Obx(() =>
                    controller.showCards.value ? cardRight() : SizedBox()),
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
                // نمایش کارت‌های متحرک بالای همه ویجت‌ها
                Obx(() => Stack(
                      children: [
                        for (final animCard in controller.animatedCards)
                          AnimatedCard(
                            key: animCard.key,
                            card: animCard.card,
                            targetPosition: animCard.targetPosition,
                            showBack: true,
                          ),
                      ],
                    )),
                // نمایش کارت‌های متحرک بازی (از دست بازیکن به مرکز)
                Obx(() => Center(
                      child: Stack(
                        children: [
                          for (final animCard in controller.animatedPlayedCards)
                            PlayedAnimatedCard(
                              key: animCard.key,
                              card: animCard.card,
                              fromPosition: animCard.fromPosition,
                              isCut: animCard.isCut,
                            ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// نمایش اطلاعات بالای صفحه شامل امتیازات و خال حکم انتخاب شده.
  Widget textTop(BuildContext context) {
    final idx = settingsController.cardBackIndex.value;
    final isColor = idx < settingsController.cardBackColors.length;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (!isLandscape) {
      // حالت عمودی
      return Positioned(
        top: 70,
        left: 35,
        right: 35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bkgText(
                  horizontal: 4,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(() => Text('شمــا: ست: '
                              '${controller.teamSets['team1']?.value}  |  دست:')),
                        ],
                      ),
                      SizedBox(width: 4),
                      Obx(() => Row(
                            children: List.generate(7, (i) {
                              if (i < controller.team1WonHands.length) {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1.5),
                                    child: isColor
                                        ? Container(
                                            width: 14,
                                            height: 21,
                                            decoration: BoxDecoration(
                                              color: settingsController
                                                  .cardBackColors[idx],
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1,
                                              ),
                                            ),
                                            child: Image.asset(
                                              settingsController.cardBackImages[
                                                  idx -
                                                      settingsController
                                                          .cardBackColors
                                                          .length],
                                              width: 13,
                                              height: 20,
                                            ),
                                          ));
                              } else {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1.5),
                                    child: Container(
                                      width: 14,
                                      height: 21,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                    ));
                              }
                            }),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                bkgText(
                  horizontal: 4,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(() => Text('حریف: ست: '
                              '${controller.teamSets['team2']?.value}  |  دست:')),
                        ],
                      ),
                      SizedBox(width: 4),
                      Obx(() => Row(
                            children: List.generate(7, (i) {
                              if (i < controller.team2WonHands.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1.5),
                                  child: isColor
                                      ? Container(
                                          width: 14,
                                          height: 21,
                                          decoration: BoxDecoration(
                                            color: settingsController
                                                .cardBackColors[idx],
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          child: Image.asset(
                                            settingsController.cardBackImages[
                                                idx -
                                                    settingsController
                                                        .cardBackColors.length],
                                            width: 13,
                                            height: 20,
                                          ),
                                        ),
                                );
                              } else {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1.5),
                                    child: Container(
                                      width: 14,
                                      height: 21,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                    ));
                              }
                            }),
                          )),
                    ],
                  ),
                ),
              ],
            ),
            Obx(() => controller.selectedHokm.value != null
                ? bkgText(
                    horizontal: 9,
                    child: Column(
                      children: [
                        Text(
                          'حکم ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        InkWell(
                          onTap: () => _showPlayedCardsDialog(context),
                          child: Image.asset(
                            'assets/drawables/${_getSuitImageName(controller.selectedHokm.value!)}',
                            width: 30,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox()),
          ],
        ),
      );
    } else {
      // حالت افقی (ساختار جدید)
      return Positioned(
        top: 44,
        left: 40,
        right: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // شما => ست و دست

            bkgText(
              child: Column(
                children: [
                  Obx(() => Text('شما = ست: '
                      '${controller.teamSets['team1']?.value} | دست: ${controller.teamScores['team1']?.value}')),
                  SizedBox(height: 5),
                  Obx(() => Row(
                        children: List.generate(7, (i) {
                          if (i < controller.team1WonHands.length) {
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: isColor
                                    ? Container(
                                        width: 14,
                                        height: 21,
                                        decoration: BoxDecoration(
                                          color: settingsController
                                              .cardBackColors[idx],
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Image.asset(
                                          settingsController.cardBackImages[
                                              idx -
                                                  settingsController
                                                      .cardBackColors.length],
                                          width: 13,
                                          height: 20,
                                        ),
                                      ));
                          } else {
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: Container(
                                  width: 14,
                                  height: 21,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                ));
                          }
                        }),
                      )),
                ],
              ),
            ),
            // حکم
            Obx(() => controller.selectedHokm.value != null
                ? Column(
                    children: [
                      SizedBox(height: 18),
                      bkgText(
                        vertical: 4,
                        child: Column(
                          children: [
                            Text(
                              'حکم',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            InkWell(
                              onTap: () => _showPlayedCardsDialog(context),
                              child: Image.asset(
                                'assets/drawables/${_getSuitImageName(controller.selectedHokm.value!)}',
                                width: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SizedBox()),
            // حریف => ست و دست

            bkgText(
              child: Column(
                children: [
                  Obx(() => Text('حریف = ست: '
                      '${controller.teamSets['team2']?.value} | دست: ${controller.teamScores['team2']?.value}')),
                  SizedBox(height: 5),
                  Obx(() => Row(
                        children: List.generate(7, (i) {
                          if (i < controller.team2WonHands.length) {
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: isColor
                                    ? Container(
                                        width: 14,
                                        height: 21,
                                        decoration: BoxDecoration(
                                          color: settingsController
                                              .cardBackColors[idx],
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                        ),
                                        child: Image.asset(
                                          settingsController.cardBackImages[
                                              idx -
                                                  settingsController
                                                      .cardBackColors.length],
                                          width: 13,
                                          height: 20,
                                        ),
                                      ));
                          } else {
                            return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: Container(
                                  width: 14,
                                  height: 21,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                ));
                          }
                        }),
                      )),
                ],
              ),
            )
          ],
        ),
      );
    }
  }

  /// ساختار پس‌زمینه متنی برای نمایش امتیازات و حکم.
  Widget bkgText(
      {required Widget child,
      double vertical = 8.0,
      double horizontal = 16.0}) {
    return Container(
        padding:
            EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(12),
            border: BoxBorder.all(color: Colors.black38)),
        child: child);
  }

  /// کارت های مرکزی
  Widget cardCenter(bool isLandscape) {
    double h = isLandscape ? 170 : 300;
    double w = isLandscape ? 350 : 180;
    return Positioned(
      bottom: 0,
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(
          () => controller.showStartButton.value
              ? SizedBox(
                  height: 60,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: controller.startGame,
                    child: Text(
                      'شروع بازی و\nانتخاب حاکم',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : SizedBox(
                  height: h,
                  width: w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // نمایش کارت‌های روی میز در حالت بازی
                      Obx(() {
                        return controller.isGameStarted.value &&
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
                                        child: CardWidget(
                                          card: entry.value,
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            : SizedBox();
                      }),
                      // نمایش کارت‌های پشته فقط زمانی که بازی شروع نشده یا در مرحله تعیین حاکم هستیم
                      if (controller.showCards.value &&
                          controller.cards.isNotEmpty)
                        for (int i = controller.cards.length - 1; i >= 0; i--)
                          Positioned(
                            child: CardWidget(
                              card: controller.cards[i],
                              //! پشت کارت ها را نمایش میدهد
                              showBack: true,
                            ),
                          ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// نمایش کارت‌های بازیکن پایین (بازیکن انسانی).
  Widget cardBotton(BuildContext context) {
    return Obx(() {
      return Positioned(
        bottom: controller.cardPositions['bottom']?.value ?? 4,
        left: 0,
        right: 0,
        child: Column(
          children: [
            if (controller.hokmPlayer.value == 'bottom') ...tajAnCir(),
            SizedBox(height: 6),
            Center(
              child: controller.playerCards['bottom']?.isNotEmpty ?? false
                  ? Builder(
                      builder: (context) {
                        final cardCount =
                            controller.playerCards['bottom']!.length;
                        final maxWidth = 900.0;
                        final cardWidth =
                            MediaQuery.of(context).size.width * 0.0626;
                        final totalWidth = cardCount * cardWidth + 52;
                        final actualWidth = math.min(totalWidth, maxWidth);
                        final spacing = cardCount > 1
                            ? (actualWidth - 52 - cardWidth) / (cardCount - 1)
                            : 0.0;
                        return SizedBox(
                          height: 113,
                          width: actualWidth,
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              for (int i = 0; i < cardCount; i++)
                                Positioned(
                                  left: i * spacing,
                                  bottom: (() {
                                    final card =
                                        controller.playerCards['bottom']![i];
                                    final canPlay =
                                        controller.isCardPlayable(card);
                                    final isSelectable =
                                        controller.isBottomPlayerTurn.value &&
                                            canPlay;
                                    return isSelectable ? 16.0 : 0.0;
                                  })(),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (controller.game.table.isEmpty) {
                                        print(
                                            '\n---------------------------------------------------\n');
                                      }
                                      final card =
                                          controller.playerCards['bottom']![i];
                                      if (controller.isBottomPlayerTurn.value &&
                                          controller.isCardPlayable(card)) {
                                        controller.playCard(card);
                                      }
                                      print(
                                          '------------------------------------ بازیکن انسانی: $card');
                                    },
                                    child: Builder(
                                      builder: (context) {
                                        final card = controller
                                            .playerCards['bottom']![i];
                                        final canPlay =
                                            controller.isCardPlayable(card);
                                        return CardWidget(
                                          key: ValueKey(
                                              '${card.rankName}_${card.suit}'),
                                          card: card,
                                          isSelectable: controller
                                                  .isBottomPlayerTurn.value &&
                                              canPlay,
                                          borderColor: controller
                                                  .isBottomPlayerTurn.value
                                              ? (canPlay
                                                  ? Colors.blue
                                                  : Colors.red)
                                              : Colors.green,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    )
                  : SizedBox(),
            ),
          ],
        ),
      );
    });
  }

  /// نمایش کارت‌های بازیکن چپ (هوش مصنوعی حریف).
  Widget cardLeft() {
    return Builder(
        builder: (context) => Obx(() => Positioned(
            left: (controller.cardPositions['left']?.value ?? 50),
            bottom: 0,
            top: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bkgText(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(controller.getPlayerName('left')),
                      if (controller.hokmPlayer.value == 'left') ...tajAnCir(),
                    ],
                  ),
                ),
                SizedBox(width: 6),
                Center(
                  child: Obx(
                    () => controller.playerCards['left']?.isNotEmpty ?? false
                        ? SizedBox(
                            height:
                                (controller.playerCards['left']!.length * 20) +
                                    86,
                            width: 75,
                            child: Stack(
                              children: [
                                for (int i = 0;
                                    i < controller.playerCards['left']!.length;
                                    i++)
                                  Positioned(
                                    top: i * 20,
                                    child: CardWidget(
                                      card: controller.playerCards['left']![i],
                                      //! پشت کارت ها را نمایش میدهد
                                      showBack:
                                          controller.isDistributingForHakem,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : SizedBox(
                            width: 70,
                          ),
                  ),
                ),
              ],
            ))));
  }

  /// نمایش کارت‌های بازیکن راست (هوش مصنوعی حریف).
  Widget cardRight() {
    return Builder(
      builder: (context) => Obx(
        () => Positioned(
          right: (controller.cardPositions['right']?.value ?? 50),
          bottom: 0,
          top: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => controller.playerCards['right']?.isNotEmpty ?? false
                    ? SizedBox(
                        height:
                            (controller.playerCards['right']!.length * 20) + 86,
                        width: 66,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            for (int i = 0;
                                i < controller.playerCards['right']!.length;
                                i++)
                              Positioned(
                                top: i * 20,
                                child: CardWidget(
                                  card: controller.playerCards['right']![i],
                                  //! پشت کارت ها را نمایش میدهد
                                  showBack: controller.isDistributingForHakem,
                                ),
                              ),
                          ],
                        ),
                      )
                    : SizedBox(width: 70),
              ),
              SizedBox(width: 6),
              bkgText(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(controller.getPlayerName('right')),
                    if (controller.hokmPlayer.value == 'right') ...tajAnCir()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// کارت های بازیکن بالا (هوش مصنوعی یار)
  Widget cardTop() {
    return Builder(
        builder: (context) => Obx(
              () => Positioned(
                top: (controller.cardPositions['top']?.value ?? 1),
                left: 4,
                right: 0,
                child: Column(
                  children: [
                    Center(
                      child: Obx(
                        () => controller.playerCards['top']?.isNotEmpty ?? false
                            ? SizedBox(
                                height: 95,
                                // height: 98,
                                width:
                                    controller.playerCards['top']!.length * 16 +
                                        66,
                                child: Stack(children: [
                                  for (int i = 0;
                                      i < controller.playerCards['top']!.length;
                                      i++)
                                    Positioned(
                                      //15
                                      bottom: 0,
                                      right: i * 17,
                                      child: CardWidget(
                                        card: controller.playerCards['top']![i],
                                        //! پشت کارت ها را نمایش میدهد
                                        showBack:
                                            controller.isDistributingForHakem,
                                      ),
                                    ),
                                ]))
                            : SizedBox(
                                // height: 70,
                                ),
                      ),
                    ),
                    SizedBox(height: 2),
                    bkgText(
                      // vertical: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(controller.getPlayerName('top')),
                          SizedBox(width: 5),
                          if (controller.hokmPlayer.value == 'top')
                            ...tajAnCir()
                        ],
                      ),
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

  /// ساخت دیالوگ انتخاب خال حکم برای بازیکن انسانی.
  Widget _buildHokmSelectionDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 400,
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
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                textDirection: TextDirection.ltr,
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

  /// ساخت دکمه انتخاب یک خال خاص در دیالوگ انتخاب حکم.
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

  /// گرفتن نام فایل عکس مربوط به یک خال.
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

  void _showPlayedCardsDialog(BuildContext context) {
    final tableHistory = controller.game.tableHistory;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('کارت‌های بازی‌شده'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < tableHistory.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text('دست ${i + 1}:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...tableHistory[i]
                              .asMap()
                              .entries
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0),
                                    child: SizedBox(
                                      width: 40,
                                      // height: 30,
                                      child: CardWidget(
                                          card: entry.value,
                                          borderColor: Colors.red),
                                    ),
                                  )),
                        ],
                      ),
                    ),
                  if (tableHistory.isEmpty)
                    Center(child: Text('هنوز کارتی بازی نشده است.')),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('بستن'),
            ),
          ],
        );
      },
    );
  }
}
