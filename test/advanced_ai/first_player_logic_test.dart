import 'package:flutter_test/flutter_test.dart';
import 'package:as_hokme/game/models/player.dart';
import 'package:as_hokme/game/models/card.dart';
import 'package:as_hokme/game/models/enums.dart';

void main() {
  group('تست منطق نفر اول (first player logic)', () {
    test('اگر آس غیر حکم داشته باشد، باید همان را بازی کند', () {
      // کارت‌ها: آس دل، شاه دل، ۷ گشنیز
      final hand = [
        GameCard(suit: Suit.hearts, rank: Rank.ace),
        GameCard(suit: Suit.hearts, rank: Rank.king),
        GameCard(suit: Suit.clubs, rank: Rank.seven),
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades, // حکم
        [], // تاریخچه
        [], // میز
        [], // تیم‌ها
        Direction.bottom,
      );
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.ace);
    });

    test(
        'اگر شاه غیر حکم داشته باشد و آس غیر حکم نداشته باشد (دست اول)، باید ضعیف‌ترین کارت همان خال شاه را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.hearts, rank: Rank.king),
        GameCard(suit: Suit.hearts, rank: Rank.seven),
        GameCard(suit: Suit.clubs, rank: Rank.nine),
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        [],
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.seven); // ضعیف‌ترین کارت همان خال شاه
    });

    test(
        'اگر خال غیر حکم با ۳ یا کمتر کارت داشته باشد (دست اول)، باید ضعیف‌ترین کارت همان خال را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.diamonds, rank: Rank.five),
        GameCard(suit: Suit.diamonds, rank: Rank.six),
        GameCard(suit: Suit.spades, rank: Rank.king),
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.hearts,
        [],
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.diamonds);
      expect(card.rank, Rank.five);
    });

    test(
        'اگر فقط کارت غیر حکم دارد (دست اول)، باید ضعیف‌ترین کارت غیر حکم را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.clubs, rank: Rank.four),
        GameCard(suit: Suit.clubs, rank: Rank.six),
        GameCard(suit: Suit.diamonds, rank: Rank.five),
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        [],
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit != Suit.spades, true);
      expect(card.rank, Rank.four);
    });

    test('اگر فقط کارت حکم دارد (دست اول)، باید ضعیف‌ترین کارت حکم را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.hearts, rank: Rank.five),
        GameCard(suit: Suit.hearts, rank: Rank.six),
        GameCard(suit: Suit.hearts, rank: Rank.seven),
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.hearts,
        [],
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.five);
    });

    test('اگر آس غیر حکم داشته باشد (دست‌های بعدی)، باید همان را بازی کند', () {
      final hand = [
        GameCard(suit: Suit.diamonds, rank: Rank.ace),
        GameCard(suit: Suit.spades, rank: Rank.king),
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        [
          [GameCard(suit: Suit.hearts, rank: Rank.five)]
        ],
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.diamonds);
      expect(card.rank, Rank.ace);
    });

    test(
        'اگر قوی‌ترین کارت غیر حکم که قطعا برنده است داشته باشد، باید همان را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.diamonds, rank: Rank.king),
        GameCard(suit: Suit.spades, rank: Rank.queen),
      ];
      final tableHistory = [
        [
          GameCard(suit: Suit.diamonds, rank: Rank.ace), // bottom
          GameCard(suit: Suit.hearts, rank: Rank.five), // left (فرضی)
          GameCard(suit: Suit.clubs, rank: Rank.four), // top (فرضی)
          GameCard(suit: Suit.spades, rank: Rank.six), // right (فرضی)
        ],
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        tableHistory,
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.diamonds);
      expect(card.rank, Rank.king);
    });

    test(
        'اگر قوی‌ترین کارت حکم که قطعا برنده است داشته باشد، باید همان را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.spades, rank: Rank.queen),
        GameCard(suit: Suit.spades, rank: Rank.jack),
      ];
      final tableHistory = [
        [
          GameCard(suit: Suit.spades, rank: Rank.ace), // bottom
          GameCard(suit: Suit.hearts, rank: Rank.five), // left (فرضی)
          GameCard(suit: Suit.clubs, rank: Rank.four), // top (فرضی)
          GameCard(suit: Suit.diamonds, rank: Rank.six), // right (فرضی)
        ],
        [
          GameCard(suit: Suit.spades, rank: Rank.king), // bottom
          GameCard(suit: Suit.hearts, rank: Rank.six), // left (فرضی)
          GameCard(suit: Suit.clubs, rank: Rank.five), // top (فرضی)
          GameCard(suit: Suit.diamonds, rank: Rank.seven), // right (فرضی)
        ],
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        tableHistory,
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.spades);
      expect(card.rank, Rank.queen);
    });

    test(
        'اگر یار خالی را بریده و تو هم آن خال را داری، باید همان خال را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.hearts, rank: Rank.five),
        GameCard(suit: Suit.spades, rank: Rank.king),
      ];
      final tableHistory = [
        [
          GameCard(suit: Suit.diamonds, rank: Rank.ace), // bottom
          GameCard(suit: Suit.hearts, rank: Rank.seven), // left (یار بریده)
          GameCard(suit: Suit.clubs, rank: Rank.four), // top (فرضی)
          GameCard(suit: Suit.spades, rank: Rank.six), // right (فرضی)
        ],
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        tableHistory,
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.five);
    });

    test(
        'اگر یار در دست قبلی یک خال غیر حکم را رد کرده و تو آن خال را داری، باید همان خال را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.hearts, rank: Rank.five),
        GameCard(suit: Suit.diamonds, rank: Rank.five),
        GameCard(suit: Suit.spades, rank: Rank.king),
      ];
      final tableHistory = [
        [
          GameCard(suit: Suit.hearts, rank: Rank.ace), // bottom (leadSuit)
          GameCard(
              suit: Suit.spades,
              rank: Rank.seven), // left (partnerCard, رد کرده)
          GameCard(suit: Suit.clubs, rank: Rank.four), // top (فرضی)
          GameCard(suit: Suit.diamonds, rank: Rank.six), // right (فرضی)
        ],
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        tableHistory,
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.five);
    });

    test(
        'اگر فقط کارت غیر حکم دارد (دست‌های بعدی)، باید ضعیف‌ترین کارت غیر حکم را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.diamonds, rank: Rank.five),
        GameCard(suit: Suit.diamonds, rank: Rank.six),
      ];
      final tableHistory = [
        [
          GameCard(suit: Suit.spades, rank: Rank.ace), // bottom
          GameCard(suit: Suit.hearts, rank: Rank.five), // left (فرضی)
          GameCard(suit: Suit.clubs, rank: Rank.four), // top (فرضی)
          GameCard(suit: Suit.diamonds, rank: Rank.six), // right (فرضی)
        ],
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        tableHistory,
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.diamonds);
      expect(card.rank, Rank.five);
    });

    test(
        'اگر فقط کارت حکم دارد (دست‌های بعدی)، باید ضعیف‌ترین کارت حکم را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.spades, rank: Rank.five),
        GameCard(suit: Suit.spades, rank: Rank.six),
      ];
      final tableHistory = [
        [
          GameCard(suit: Suit.hearts, rank: Rank.ace), // bottom
          GameCard(suit: Suit.diamonds, rank: Rank.five), // left (فرضی)
          GameCard(suit: Suit.clubs, rank: Rank.four), // top (فرضی)
          GameCard(suit: Suit.spades, rank: Rank.seven), // right (فرضی)
        ],
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      final card = player.firstCard(
        Suit.spades,
        tableHistory,
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.spades);
      expect(card.rank, Rank.five);
    });

    test(
        'اگر lastPartnerSuit مقدار داشته باشد و کارت از آن خال داشته باشد، باید ضعیف‌ترین کارت همان خال را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.diamonds, rank: Rank.five),
        GameCard(suit: Suit.hearts, rank: Rank.six),
      ];
      final player =
          PlayerAI('AI', Direction.bottom, hand, aiLevel: 2, isPartner: false);
      player.lastPartnerSuit = Suit.diamonds;
      final card = player.firstCard(
        Suit.spades,
        [],
        [],
        [],
        Direction.bottom,
      );
      expect(card.suit, Suit.diamonds);
      expect(card.rank, Rank.five);
    });

    // تست‌های بیشتر بر اساس منطق نفر اول...
  });
}
