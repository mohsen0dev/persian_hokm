import 'package:flutter_test/flutter_test.dart';
import 'package:as_hokme/game/models/player.dart';
import 'package:as_hokme/game/models/card.dart';
import 'package:as_hokme/game/models/enums.dart';
import 'package:as_hokme/game/models/team.dart';

void main() {
  group('Partner Suit Memory', () {
    test('فقط یار نفر اول دست قبلی باید lastPartnerSuit بگیرد', () {
      // بازیکنان و تیم‌ها
      final p1 =
          PlayerAI('P1', Direction.bottom, [], aiLevel: 2, isPartner: false);
      final p2 =
          PlayerAI('P2', Direction.right, [], aiLevel: 2, isPartner: false);
      final p3 = PlayerAI('P3', Direction.top, [], aiLevel: 2, isPartner: true);
      final p4 =
          PlayerAI('P4', Direction.left, [], aiLevel: 2, isPartner: true);
      final List<PlayerAI> players = [p1, p2, p3, p4];
      final teams = [Team(p1, p3), Team(p2, p4)];
      for (var p in players) {
        p.team = p.direction == Direction.bottom || p.direction == Direction.top
            ? teams[0]
            : teams[1];
      }
      // دست: P1: diamonds, P2: hearts, P3: clubs, P4: spades
      final hand = [
        GameCard(suit: Suit.diamonds, rank: Rank.ace), // P1
        GameCard(suit: Suit.hearts, rank: Rank.ace), // P2
        GameCard(suit: Suit.clubs, rank: Rank.ace), // P3
        GameCard(suit: Suit.spades, rank: Rank.ace), // P4
      ];
      // P1 شروع‌کننده است
      final starterDirection = Direction.bottom;
      int starterIdx =
          players.indexWhere((p) => p.direction == starterDirection);
      for (int i = 0; i < 4; i++) {
        final player = players[i];
        final partner = player.team.playerA == player
            ? player.team.playerB
            : player.team.playerA;
        int partnerOffset = players.indexWhere((p) => p == partner);
        final partnerCard = hand[partnerOffset];
        if (partnerOffset == starterIdx) {
          player.updateLastPartnerSuit(partnerCard.suit);
        }
      }
      // فقط P3 باید مقدار بگیرد (یار P1)
      expect(p3.lastPartnerSuit, Suit.diamonds);
      expect(p1.lastPartnerSuit, isNull);
      expect(p2.lastPartnerSuit, isNull);
      expect(p4.lastPartnerSuit, isNull);
    });

    test('اگر یار نفر دوم، سوم یا چهارم باشد، مقدار نگیرد', () {
      // بازیکنان و تیم‌ها
      final p1 =
          PlayerAI('P1', Direction.bottom, [], aiLevel: 2, isPartner: false);
      final p2 =
          PlayerAI('P2', Direction.right, [], aiLevel: 2, isPartner: false);
      final p3 = PlayerAI('P3', Direction.top, [], aiLevel: 2, isPartner: true);
      final p4 =
          PlayerAI('P4', Direction.left, [], aiLevel: 2, isPartner: true);
      final List<PlayerAI> players = [p1, p2, p3, p4];
      final teams = [Team(p1, p3), Team(p2, p4)];
      for (var p in players) {
        p.team = p.direction == Direction.bottom || p.direction == Direction.top
            ? teams[0]
            : teams[1];
      }
      // دست: P1: hearts, P2: diamonds (starter), P3: clubs, P4: spades
      final hand = [
        GameCard(suit: Suit.hearts, rank: Rank.ace), // P1
        GameCard(suit: Suit.diamonds, rank: Rank.ace), // P2 (starter)
        GameCard(suit: Suit.clubs, rank: Rank.ace), // P3
        GameCard(suit: Suit.spades, rank: Rank.ace), // P4
      ];
      final starterDirection = Direction.right;
      int starterIdx =
          players.indexWhere((p) => p.direction == starterDirection);
      for (int i = 0; i < 4; i++) {
        final player = players[i];
        final partner = player.team.playerA == player
            ? player.team.playerB
            : player.team.playerA;
        int partnerOffset = players.indexWhere((p) => p == partner);
        final partnerCard = hand[partnerOffset];
        if (partnerOffset == starterIdx) {
          player.updateLastPartnerSuit(partnerCard.suit);
        }
      }
      // فقط P4 باید diamonds بگیرد (یار P2)
      expect(p4.lastPartnerSuit, Suit.diamonds);
      expect(p1.lastPartnerSuit, isNull);
      expect(p2.lastPartnerSuit, isNull);
      expect(p3.lastPartnerSuit, isNull);
    });

    test(
        'سناریوی واقعی: یار نفر اول مقدار می‌گیرد و اگر شروع‌کننده باشد همان خال را بازی می‌کند',
        () {
      final p1 =
          PlayerAI('P1', Direction.bottom, [], aiLevel: 2, isPartner: false);
      final p2 =
          PlayerAI('P2', Direction.right, [], aiLevel: 2, isPartner: false);
      final p3 = PlayerAI('P3', Direction.top, [], aiLevel: 2, isPartner: true);
      final p4 =
          PlayerAI('P4', Direction.left, [], aiLevel: 2, isPartner: true);
      final List<PlayerAI> players = [p1, p2, p3, p4];
      final teams = [Team(p1, p3), Team(p2, p4)];
      for (var p in players) {
        p.team = p.direction == Direction.bottom || p.direction == Direction.top
            ? teams[0]
            : teams[1];
      }
      // دست اول: P1: 3خشت، P2: 6خشت، P3: آس خشت، P4: 4خشت
      final hand1 = [
        GameCard(suit: Suit.diamonds, rank: Rank.three), // P1
        GameCard(suit: Suit.diamonds, rank: Rank.six), // P2
        GameCard(suit: Suit.diamonds, rank: Rank.ace), // P3
        GameCard(suit: Suit.diamonds, rank: Rank.four), // P4
      ];
      final starterDirection1 = Direction.bottom;
      int starterIdx1 =
          players.indexWhere((p) => p.direction == starterDirection1);
      for (int i = 0; i < 4; i++) {
        final player = players[i];
        final partner = player.team.playerA == player
            ? player.team.playerB
            : player.team.playerA;
        int partnerOffset = players.indexWhere((p) => p == partner);
        final partnerCard = hand1[partnerOffset];
        if (partnerOffset == starterIdx1) {
          player.updateLastPartnerSuit(partnerCard.suit);
        }
      }
      // فقط P3 باید diamonds بگیرد
      expect(p3.lastPartnerSuit, Suit.diamonds);
      expect(p1.lastPartnerSuit, isNull);
      expect(p2.lastPartnerSuit, isNull);
      expect(p4.lastPartnerSuit, isNull);
      // دست دوم: P3 شروع‌کننده است و diamonds دارد
      p3.hand.clear();
      p3.hand.addAll([
        GameCard(suit: Suit.diamonds, rank: Rank.five),
        GameCard(suit: Suit.diamonds, rank: Rank.two),
        GameCard(suit: Suit.hearts, rank: Rank.ace),
      ]);
      final cardPlayed = p3.firstCard(
        Suit.hearts, // فرضاً حکم hearts است
        [], // tableHistory
        [], // table
        teams,
        Direction.top, // starterDirection
      );
      expect(cardPlayed.suit, Suit.diamonds);
      expect(cardPlayed.rank, Rank.two);
    });
  });
}
