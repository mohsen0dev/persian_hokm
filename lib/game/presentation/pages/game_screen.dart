import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/presentation/controllers/game_controller.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';
import 'package:persian_hokm/game/presentation/widgets/animated_card.dart';
import 'package:persian_hokm/game/presentation/widgets/card_widget.dart';
import 'package:persian_hokm/game/presentation/widgets/played_animated_card.dart';
import 'package:persian_hokm/game/models/player.dart';
import 'package:persian_hokm/game/enums.dart';

/// کلاس اصلی صفحه بازی حکم
/// این کلاس واسط کاربری بازی را نمایش می‌دهد و با GameController برای مدیریت منطق بازی تعامل دارد.
class GameScreen extends StatelessWidget {
  /// کنترلر اصلی بازی که منطق و وضعیت بازی را مدیریت می‌کند.
  final controller = Get.put(GameController());

  /// کنترلر تنظیمات برای دسترسی به تنظیمات پس‌زمینه و غیره.
  final settingsController = Get.put(SettingsController());

  /// سازنده کلاس GameScreen.
  GameScreen({super.key});

  /// متد اصلی ساخت واسط کاربری صفحه بازی.
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
        return Scaffold(
          body: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              isColor
                  ? Container(color: settingsController.backgroundColors[idx])
                  : Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(settingsController.backgroundImages[
                              idx -
                                  settingsController.backgroundColors.length]),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
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
              // نمایش کارت‌های متحرک بالای همه ویجت‌ها
              Obx(() => Stack(
                    children: [
                      for (final animCard in controller.animatedCards)
                        AnimatedCard(
                          key: animCard.key,
                          card: animCard.card,
                          targetPosition: animCard.targetPosition,
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
        );
      }),
    );
  }

  /// نمایش اطلاعات بالای صفحه شامل امتیازات و خال حکم انتخاب شده.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی اطلاعات بالای صفحه.
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

  /// ساختار پس‌زمینه متنی برای نمایش امتیازات و حکم.
  /// یک Container با استایل خاص (پس‌زمینه خاکستری و گوشه‌های گرد) ایجاد می‌کند.
  ///
  /// Args:
  ///   child: ویجت فرزند که درون Container قرار می‌گیرد (مانند متن امتیازات).
  ///
  /// Returns:
  ///   ویجت Container با استایل پس‌زمینه.
  Container bkgText({required Widget child}) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child);
  }

  /// نمایش پشته کارت‌ها در مرکز صفحه (قبل از شروع بازی) یا کارت‌های روی میز (هنگام بازی).
  /// وضعیت‌های مختلف (نمایش دکمه شروع، نمایش پشته کارت یا کارت‌های روی میز) را مدیریت می‌کند.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی Stack برای نمایش کارت‌های مرکز.
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
              : SizedBox(
                  height: 150,
                  width: 250,
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
  /// موقعیت کارت‌ها را در پایین صفحه مدیریت می‌کند و امکان تعامل با کارت‌ها (انتخاب برای بازی) را فراهم می‌سازد.
  /// همچنین تاج حاکم را در صورت لزوم نمایش می‌دهد.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی کارت‌های بازیکن پایین.
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
                                width:
                                    controller.playerCards['bottom']!.length *
                                            (MediaQuery.of(context).size.width *
                                                0.0526) +
                                        30,
                                // width: MediaQuery.of(context).size.width * 0.7,
                                child: Stack(
                                    // alignment: Alignment.center,
                                    children: [
                                      for (int i = 0;
                                          i <
                                              controller.playerCards['bottom']!
                                                  .length;
                                          i++)
                                        Positioned(
                                          // right: 1,

                                          left: i *
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.0526),
                                          child: GestureDetector(
                                            onTap: () {
                                              final card = controller
                                                  .playerCards['bottom']![i];
                                              if (controller.isBottomPlayerTurn
                                                      .value &&
                                                  controller
                                                      .canPlayCard(card)) {
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

  /// نمایش کارت‌های بازیکن چپ (هوش مصنوعی حریف).
  /// کارت‌ها را در سمت چپ صفحه به صورت عمودی نمایش می‌دهد و تاج حاکم را در صورت لزوم نمایش می‌دهد.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی کارت‌های بازیکن چپ.
  Widget cardLeft() {
    return Builder(
        builder: (context) => Obx(() => Positioned(
            left: (controller.cardPositions['left']?.value ?? 50) + 50,
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
                            height: 330,
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
                                            0.4),
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

  /// نمایش کارت‌های بازیکن راست (هوش مصنوعی حریف).
  /// کارت‌ها را در سمت راست صفحه به صورت عمودی نمایش می‌دهد و تاج حاکم را در صورت لزوم نمایش می‌دهد.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی کارت‌های بازیکن راست.
  Widget cardRight() {
    return Builder(
      builder: (context) => Obx(
        () => Positioned(
          right: (controller.cardPositions['right']?.value ?? 50) + 50,
          bottom: 0,
          top: 0,
          child: Row(
            children: [
              Center(
                child: Obx(
                  () => controller.playerCards['right']?.isNotEmpty ?? false
                      ? SizedBox(
                          height: 330,
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
                                          0.4),
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

  /// نمایش کارت‌های بازیکن بالا (هوش مصنوعی یار).
  /// کارت‌ها را در بالای صفحه به صورت افقی نمایش می‌دهد و تاج حاکم را در صورت لزوم نمایش می‌دهد.
  ///
  /// Returns:
  ///   ویجت Positioned حاوی کارت‌های بازیکن بالا.
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

  /// ویجت‌های نمایش دهنده تاج حاکم.
  ///
  /// Returns:
  ///   لیستی از ویجت‌ها (شامل عکس تاج).
  List<Widget> tajAnCir() {
    return [
      Image.asset(
        'assets/drawables/taj.png',
        height: 20,
      ),
    ];
  }

  /// ساخت دیالوگ انتخاب خال حکم برای بازیکن انسانی.
  /// زمانی نمایش داده می‌شود که حاکم بازیکن پایین باشد و نیاز به انتخاب حکم باشد.
  ///
  /// Returns:
  ///   ویجت Container حاوی دیالوگ انتخاب حکم.
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

  /// ساخت دکمه انتخاب یک خال خاص در دیالوگ انتخاب حکم.
  ///
  /// Args:
  ///   suit: خال مربوط به دکمه (Hearts, Clubs, Diamonds, Spades).
  ///   imageName: نام فایل عکس مربوط به خال.
  ///
  /// Returns:
  ///   ویجت InkWell حاوی دکمه انتخاب خال.
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
  ///
  /// Args:
  ///   suit: خال مورد نظر.
  ///
  /// Returns:
  ///   نام فایل عکس (String) مربوط به خال.
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

// -------------------- توابع کمکی هوش مصنوعی پیشرفته --------------------

/// بررسی اینکه آیا کارت داده شده قوی‌ترین کارت باقی‌مانده از آن خال است یا نه
bool isStrongestCard(GameCard card, List<GameCard> playedCards) {
  final suit = card.suit;
  final playedRanks =
      playedCards.where((c) => c.suit == suit).map((c) => c.rank).toSet();
  // اگر همه کارت‌های قوی‌تر بازی شده‌اند، این کارت قوی‌ترین است
  return Rank.values
      .where((r) => r.index < card.rank.index)
      .every((r) => playedRanks.contains(r));
}

/// پیدا کردن ضعیف‌ترین کارت از یک لیست کارت
GameCard weakestCard(List<GameCard> cards) {
  return cards.reduce((a, b) => a.rank.index < b.rank.index ? b : a);
}

/// پیدا کردن قوی‌ترین کارت از یک لیست کارت
GameCard strongestCard(List<GameCard> cards) {
  return cards.reduce((a, b) => a.rank.index < b.rank.index ? a : b);
}

/// بررسی اینکه آیا یار در دست قبلی یک خال را برید و تو هم از آن خال داری
GameCard? partnerCutSuitAndYouHaveIt({
  required Direction myDirection,
  required List<GameCard> hand,
  required List<List<GameCard>> tableHistory,
  required Suit hokm,
}) {
  if (tableHistory.isEmpty) return null;
  final lastHand = tableHistory.last;
  final leadSuit = lastHand.first.suit;
  // تعیین یار
  final partnerDir = myDirection == Direction.bottom
      ? Direction.top
      : myDirection == Direction.top
          ? Direction.bottom
          : myDirection == Direction.left
              ? Direction.right
              : Direction.left;
  final partnerCard = lastHand[partnerDir.index];
  // اگر یار حکم انداخته و خال اصلی را نداشته
  if (partnerCard.suit == hokm && partnerCard.suit != leadSuit) {
    final mySuitCards = hand.where((c) => c.suit == leadSuit).toList();
    if (mySuitCards.isNotEmpty) {
      // آیا قوی‌ترین کارت را داری؟
      final playedSuitCards = tableHistory
          .expand((l) => l)
          .where((c) => c.suit == leadSuit)
          .toList();
      for (final card in mySuitCards) {
        if (isStrongestCard(card, playedSuitCards)) {
          return card;
        }
      }
      // اگر قوی‌ترین را نداری، ضعیف‌ترین کارت را بازی کن
      return weakestCard(mySuitCards);
    }
  }
  return null;
}

/// بررسی اینکه آیا حریف کارت قوی از یک خال دارد و تو هم از آن خال داری، سعی کن آن خال را بازی نکنی
GameCard? avoidStrongOpponentSuit({
  required List<GameCard> hand,
  required List<List<GameCard>> tableHistory,
  required Suit hokm,
}) {
  for (final suit in Suit.values.where((s) => s != hokm)) {
    final mySuitCards = hand.where((c) => c.suit == suit).toList();
    if (mySuitCards.isEmpty) continue;
    final playedSuitCards =
        tableHistory.expand((l) => l).where((c) => c.suit == suit).toList();
    bool acePlayed = playedSuitCards.any((c) => c.rank == Rank.ace);
    bool kingPlayed = playedSuitCards.any((c) => c.rank == Rank.king);
    if (!acePlayed || !kingPlayed) {
      // سعی کن این خال را بازی نکنی
      continue;
    }
    // اگر مجبور شدی، ضعیف‌ترین کارت را بازی کن
    return weakestCard(mySuitCards);
  }
  return null;
}

/// بررسی اینکه آیا یک حریف قبلا یک خال غیر حکم را با حکم بریده است
Set<Suit> opponentPreviouslyCutSuitWithHokm({
  required List<List<GameCard>> tableHistory,
  required Suit hokm,
  required Direction myDirection,
  required List<Player> players,
}) {
  final cutSuits = <Suit>{};
  final myPartnerDir = myDirection == Direction.bottom
      ? Direction.top
      : myDirection == Direction.top
          ? Direction.bottom
          : myDirection == Direction.left
              ? Direction.right
              : Direction.left;

  for (final hand in tableHistory) {
    if (hand.length != 4) continue; // Sanity check

    final leadCard = hand.first;
    final winningCard = strongestCard(hand);
    final winnerPlayer = winningCard.player!;

    // Check if the winner was an opponent (not me and not my partner)
    if (winnerPlayer.direction != myDirection &&
        winnerPlayer.direction != myPartnerDir) {
      // Check if the winning card was hokm and played on a non-hokm lead suit
      if (winningCard.suit == hokm && leadCard.suit != hokm) {
        cutSuits.add(leadCard.suit);
      }
    }
  }

  return cutSuits;
}

// -------------------- پایان توابع کمکی هوش مصنوعی --------------------

/// مدل داده‌ای برای کارت متحرک
class AnimatedCardData {
  final GameCard card;
  final String targetPosition; // 'bottom', 'right', 'top', 'left'
  final UniqueKey key;
  AnimatedCardData({required this.card, required this.targetPosition})
      : key = UniqueKey();
}

/// مدل داده‌ای برای کارت متحرک هنگام بازی (از دست بازیکن به مرکز)
class PlayedAnimatedCardData {
  final GameCard card;
  final String fromPosition; // 'bottom', 'right', 'top', 'left'
  final bool isCut; // آیا این کارت برش است؟
  final UniqueKey key;
  PlayedAnimatedCardData(
      {required this.card, required this.fromPosition, this.isCut = false})
      : key = UniqueKey();
}
