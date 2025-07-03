import 'package:flutter_test/flutter_test.dart';
import 'package:persian_hokm/game/models/player.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/models/enums.dart';

void main() {
  group('تست منطق نفر چهارم (fourth player logic)', () {
    test(
        'اگر کارت همان خال را داشته باشد و یار برنده باشد، باید ضعیف‌ترین همان خال را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.hearts, rank: Rank.four),
        GameCard(suit: Suit.hearts, rank: Rank.six),
      ];
      final table = [
        GameCard(suit: Suit.hearts, rank: Rank.king), // نفر اول
        GameCard(suit: Suit.hearts, rank: Rank.ace), // یار (نفر دوم)
        GameCard(suit: Suit.hearts, rank: Rank.ten), // نفر سوم
      ];
      final player =
          PlayerAI('AI', Direction.right, hand, aiLevel: 2, isPartner: false);
      final card = player.fourthCard(
        Suit.spades, // حکم
        [], // تاریخچه
        table,
        [], // تیم‌ها
      );
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.four);
    });
    // تست‌های بیشتر بر اساس منطق نفر چهارم...
  });
}
