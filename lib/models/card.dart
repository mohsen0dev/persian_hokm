enum Suit {
  hearts, // گشنیز
  diamonds, // خشت
  clubs, // پیک
  spades // دل
}

extension SuitExtension on Suit {
  String get suitName {
    switch (this) {
      case Suit.hearts:
        return 'دل';
      case Suit.diamonds:
        return 'خشت';
      case Suit.clubs:
        return 'پیک';
      case Suit.spades:
        return 'گیشنیز';
    }
  }

  String get suitSymbol {
    switch (this) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }
}

enum Rank {
  ace,
  king,
  queen,
  jack,
  ten,
  nine,
  eight,
  seven,
  six,
  five,
  four,
  three,
  two
}

extension RankExtension on Rank {
  String get rankName {
    switch (this) {
      case Rank.ace:
        return 'آس';
      case Rank.king:
        return 'شاه';
      case Rank.queen:
        return 'بیبی';
      case Rank.jack:
        return 'سرباز';
      case Rank.ten:
        return '10';
      case Rank.nine:
        return '9';
      case Rank.eight:
        return '8';
      case Rank.seven:
        return '7';
      case Rank.six:
        return '6';
      case Rank.five:
        return '5';
      case Rank.four:
        return '4';
      case Rank.three:
        return '3';
      case Rank.two:
        return '2';
    }
  }
}

class GameCard {
  final Suit suit;
  final Rank rank;
  bool isSelected = false;

  GameCard({required this.suit, required this.rank});

  String get suitName => suit.suitName;

  String get rankName => rank.rankName;

  @override
  String toString() {
    return '$rankName $suitName';
  }
}
