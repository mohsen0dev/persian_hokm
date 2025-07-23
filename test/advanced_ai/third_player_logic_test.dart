import 'package:flutter_test/flutter_test.dart';
import 'package:persian_hokm/game/models/player.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/models/enums.dart';
import 'package:persian_hokm/game/models/team.dart';

void main() {
  group('Third Player Logic (thirdCard)', () {
    // ابزار ساخت بازیکن و تیم
    PlayerAI buildPlayer(Direction dir, List<GameCard> hand, Team team) {
      final p = PlayerAI('P', dir, hand, aiLevel: 2, isPartner: false);
      p.team = team;
      return p;
    }

    Team buildTeam(Player a, Player b) {
      final t = Team(a, b);
      a.team = t;
      b.team = t;
      return t;
    }

    test(
        'اگر نفر دوم با حکم زده و کارت همان خال داری، ضعیف‌ترین همان خال را بازی کن',
        () {
      // table: [firstCard, secondCard], hand: [همان خال]
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard
        GameCard(suit: Suit.diamonds, rank: Rank.ace), // secondCard (بریده)
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test(
        'اگر کارت همان خال داری و یار واقعاً برنده است، ضعیف‌ترین همان خال را بازی کن',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      // table: [firstCard, secondCard]، فرض کنیم partnerIsTrulyWinning=true
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.king), // secondCard
      ];
      // همه کارت‌های hearts بازی شده‌اند به جز کارت‌های دست player
      final tableHistory = [
        [
          GameCard(suit: Suit.hearts, rank: Rank.three),
          GameCard(suit: Suit.hearts, rank: Rank.four),
        ]
      ];
      final card = player.thirdCard(Suit.diamonds, tableHistory, table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test(
        'اگر کارت همان خال داری و یار فعلاً برنده است و کارت برنده داری، قوی‌ترین کارت برنده را بازی کن',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.five), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.four), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test(
        'اگر کارت همان خال داری و یار فعلاً برنده است و کارت برنده نداری، ضعیف‌ترین همان خال را بازی کن',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.five), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.four), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test(
        'اگر کارت همان خال داری و یار برنده نیست و کارت برنده داری، قوی‌ترین کارت برنده را بازی کن',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.king), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test(
        'اگر کارت همان خال داری و یار برنده نیست و کارت برنده نداری، ضعیف‌ترین همان خال را بازی کن',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.king), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test(
        'اگر کارت همان خال نداری و یار واقعاً برنده است، ضعیف‌ترین غیرحکم را بازی کن',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.clubs, rank: Rank.five),
            GameCard(suit: Suit.spades, rank: Rank.two),
          ],
          team);
      // فرض کنیم partnerIsTrulyWinning=true
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.king), // secondCard
      ];
      final tableHistory = [
        [
          GameCard(suit: Suit.hearts, rank: Rank.three),
          GameCard(suit: Suit.hearts, rank: Rank.four),
        ]
      ];
      final card = player.thirdCard(Suit.diamonds, tableHistory, table, [team]);
      expect(card.suit != Suit.diamonds, true); // غیرحکم
    });

    test(
        'اگر کارت همان خال نداری و حکم داری و می‌توانی با حکم قوی‌تر دست را ببری، ضعیف‌ترین حکم برنده را بازی کن',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.diamonds, rank: Rank.five), // حکم
            GameCard(suit: Suit.clubs, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.king), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      // اگر یار واقعاً برنده است، باید کارت غیرحکم بازی شود
      expect(card.suit, isNot(Suit.diamonds));
    });

    test('اگر کارت همان خال نداری و فقط حکم داری، ضعیف‌ترین حکم را بازی کن',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.diamonds, rank: Rank.five), // حکم
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.king), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.diamonds);
      expect(card.rank, Rank.five);
    });

    test('اگر نه حکم داری نه همان خال، ضعیف‌ترین غیرحکم را بازی کن', () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.clubs, rank: Rank.five),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.king), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, isNot(Suit.diamonds));
    });

    test(
        'اگر روی میز آس دل باشد و دست بازیکن 2 دل و 5 دل باشد، باید 2 دل بازی شود',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.king), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test(
        'اگر روی میز 6 دل و 7 دل باشد و دست بازیکن 2 دل و 5 دل باشد، باید 2 دل بازی شود',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.six), // firstCard (یار)
        GameCard(suit: Suit.hearts, rank: Rank.seven), // secondCard
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test('نفر اول اگر فقط دو دل و پنج دل دارد باید دو دل بازی کند', () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.bottom,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = <GameCard>[];
      final tableHistory = <List<GameCard>>[];
      final card = player.firstCard(
          Suit.diamonds, tableHistory, table, [team], Direction.bottom);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test('نفر دوم اگر فقط دو دل و پنج دل دارد باید دو دل بازی کند', () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.right, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.right,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [GameCard(suit: Suit.hearts, rank: Rank.king)];
      final tableHistory = <List<GameCard>>[];
      final card =
          player.secondCard(Suit.diamonds, tableHistory, table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test('نفر چهارم اگر فقط دو دل و پنج دل دارد باید دو دل بازی کند', () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.left, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.left,
          [
            GameCard(suit: Suit.hearts, rank: Rank.five),
            GameCard(suit: Suit.hearts, rank: Rank.two),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.king),
        GameCard(suit: Suit.hearts, rank: Rank.queen),
        GameCard(suit: Suit.hearts, rank: Rank.jack),
      ];
      final tableHistory = <List<GameCard>>[];
      final card =
          player.fourthCard(Suit.diamonds, tableHistory, table, [team]);
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.two);
    });

    test(
        'اگر نفر اول غیرحکم بازی کند، نفر دوم با 8 حکم ببرد و نفر سوم فقط 3 و 5 حکم داشته باشد، باید 3 حکم بازی کند',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.diamonds, rank: Rank.three),
            GameCard(suit: Suit.diamonds, rank: Rank.five),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (غیرحکم)
        GameCard(
            suit: Suit.diamonds,
            rank: Rank.eight), // secondCard (بریده با 8 حکم)
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.diamonds);
      expect(card.rank, Rank.three);
    });

    test(
        'اگر نفر اول غیرحکم بازی کند، نفر دوم با 8 حکم ببرد و نفر سوم فقط 3 و 9 و 10 حکم داشته باشد، باید 9 حکم بازی کند',
        () {
      final team = buildTeam(
          PlayerAI('A', Direction.bottom, [], aiLevel: 2, isPartner: false),
          PlayerAI('B', Direction.top, [], aiLevel: 2, isPartner: false));
      final player = buildPlayer(
          Direction.top,
          [
            GameCard(suit: Suit.diamonds, rank: Rank.three),
            GameCard(suit: Suit.diamonds, rank: Rank.nine),
            GameCard(suit: Suit.diamonds, rank: Rank.ten),
          ],
          team);
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // firstCard (غیرحکم)
        GameCard(
            suit: Suit.diamonds,
            rank: Rank.eight), // secondCard (بریده با 8 حکم)
      ];
      final card = player.thirdCard(Suit.diamonds, [], table, [team]);
      expect(card.suit, Suit.diamonds);
      expect(card.rank, Rank.nine);
    });
  });
}
