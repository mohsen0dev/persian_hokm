import 'package:flutter_test/flutter_test.dart';
import 'package:persian_hokm/game/models/player.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/models/enums.dart';

void main() {
  group('تست منطق نفر دوم (second player logic)', () {
    test(
        'اگر کارت همان خال را داشته باشد و قوی‌ترین باشد، باید همان را بازی کند',
        () {
      final hand = [
        GameCard(suit: Suit.hearts, rank: Rank.ace),
        GameCard(suit: Suit.hearts, rank: Rank.king),
      ];
      final table = [GameCard(suit: Suit.hearts, rank: Rank.king)];
      final player =
          PlayerAI('AI', Direction.left, hand, aiLevel: 2, isPartner: false);
      final card = player.secondCard(
        Suit.spades, // حکم
        [], // تاریخچه
        table,
        [], // تیم‌ها
      );
      expect(card.suit, Suit.hearts);
      expect(card.rank, Rank.ace);
    });
    // تست‌های بیشتر بر اساس منطق نفر دوم...
  });
}
