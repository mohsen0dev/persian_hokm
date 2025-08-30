import 'package:flutter_test/flutter_test.dart';
import 'package:as_hokme/game/models/player.dart';
import 'package:as_hokme/game/models/card.dart';
import 'package:as_hokme/game/models/enums.dart';
import 'package:as_hokme/game/models/team.dart';

void main() {
  testWidgets('شبیه‌سازی یک دور بازی حکم با ۴ بازیکن AI و تعیین برنده دست',
      (WidgetTester tester) async {
    // ساخت دست اولیه برای هر بازیکن
    final hand1 = [
      GameCard(suit: Suit.hearts, rank: Rank.ace),
      GameCard(suit: Suit.spades, rank: Rank.king),
      GameCard(suit: Suit.clubs, rank: Rank.seven),
    ];
    final hand2 = [
      GameCard(suit: Suit.hearts, rank: Rank.king),
      GameCard(suit: Suit.spades, rank: Rank.queen),
      GameCard(suit: Suit.clubs, rank: Rank.eight),
    ];
    final hand3 = [
      GameCard(suit: Suit.hearts, rank: Rank.queen),
      GameCard(suit: Suit.spades, rank: Rank.jack),
      GameCard(suit: Suit.clubs, rank: Rank.nine),
    ];
    final hand4 = [
      GameCard(suit: Suit.hearts, rank: Rank.jack),
      GameCard(suit: Suit.spades, rank: Rank.ten),
      GameCard(suit: Suit.clubs, rank: Rank.ten),
    ];

    // ساخت بازیکنان AI
    final player1 = PlayerAI('AI1', Direction.bottom, List.from(hand1),
        aiLevel: 2, isPartner: false);
    final player2 = PlayerAI('AI2', Direction.left, List.from(hand2),
        aiLevel: 2, isPartner: false);
    final player3 = PlayerAI('AI3', Direction.top, List.from(hand3),
        aiLevel: 2, isPartner: false);
    final player4 = PlayerAI('AI4', Direction.right, List.from(hand4),
        aiLevel: 2, isPartner: false);

    // فرض: حکم دل است
    final hokm = Suit.hearts;
    final tableHistory = <List<GameCard>>[];
    final table = <GameCard>[];
    final List<Team> teams = [];

    // هر بازیکن یک کارت بازی می‌کند (یک دور کامل)
    final card1 = player1.play(
      table: table,
      tableHistory: tableHistory,
      teams: teams,
      hokm: hokm,
      starterDirection: Direction.bottom,
    );
    player1.hand.remove(card1);
    table.add(card1);

    final card2 = player2.play(
      table: table,
      tableHistory: tableHistory,
      teams: teams,
      hokm: hokm,
      starterDirection: Direction.bottom,
    );
    player2.hand.remove(card2);
    table.add(card2);

    final card3 = player3.play(
      table: table,
      tableHistory: tableHistory,
      teams: teams,
      hokm: hokm,
      starterDirection: Direction.bottom,
    );
    player3.hand.remove(card3);
    table.add(card3);

    final card4 = player4.play(
      table: table,
      tableHistory: tableHistory,
      teams: teams,
      hokm: hokm,
      starterDirection: Direction.bottom,
    );
    player4.hand.remove(card4);
    table.add(card4);

    // بعد از یک دور، باید هر بازیکن یک کارت کمتر داشته باشد
    expect(player1.hand.length, 2);
    expect(player2.hand.length, 2);
    expect(player3.hand.length, 2);
    expect(player4.hand.length, 2);

    // جدول باید ۴ کارت داشته باشد
    expect(table.length, 4);

    // تعیین برنده دست (با توجه به حکم)
    GameCard strongestCard(List<GameCard> cards, {Suit? hokm}) {
      if (cards.isEmpty) throw Exception('No cards on table');
      final leadSuit = cards.first.suit;
      // اگر حکم روی میز باشد، قوی‌ترین حکم برنده است
      final hokmCards =
          hokm != null ? cards.where((c) => c.suit == hokm).toList() : [];
      if (hokmCards.isNotEmpty) {
        hokmCards.sort((a, b) => a.rank.index.compareTo(b.rank.index));
        return hokmCards.first;
      }
      // در غیر این صورت، قوی‌ترین کارت خال شروع‌کننده برنده است
      final leadSuitCards = cards.where((c) => c.suit == leadSuit).toList();
      leadSuitCards.sort((a, b) => a.rank.index.compareTo(b.rank.index));
      return leadSuitCards.first;
    }

    final winnerCard = strongestCard(table, hokm: hokm);
    // انتظار داریم برنده دست، آس دل باشد (AI1)
    expect(winnerCard.suit, Suit.hearts);
    expect(winnerCard.rank, Rank.ace);
  });
}
