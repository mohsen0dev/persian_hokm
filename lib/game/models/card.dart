/// خال کارت
enum Suit {
  hearts, // دل
  diamonds, // خشت
  clubs, // گشنیز
  spades // پیک
}

/// اکسنسیون خال کارت
extension SuitExtension on Suit {
  /// نام خال
  String get suitName {
    switch (this) {
      case Suit.hearts:
        return 'دل';
      case Suit.clubs:
        return 'گیشنیز';
      case Suit.diamonds:
        return 'خشت';
      case Suit.spades:
        return 'پیک';
    }
  }

  /// علامت خال
  String get suitSymbol {
    switch (this) {
      case Suit.hearts:
        return '♥';
      case Suit.clubs:
        return '♣';
      case Suit.diamonds:
        return '♦';
      case Suit.spades:
        return '♠';
    }
  }
}

/// اکسنسیون رنک
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

/// اکسنسیون رنک
extension RankExtension on Rank {
  /// نام رنک
  String get rankName {
    switch (this) {
      case Rank.ace:
        return 'آس';
      case Rank.king:
        return 'شاه';
      case Rank.queen:
        return 'بی بی';
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
  //! خال کارت
  final Suit suit;

  //! رنک کارت
  final Rank rank;

  //! انتخاب شده
  bool isSelected = false;

  //! بازیکن صاحب کارت
  dynamic player;
  // بازیکن صاحب کارت (nullable). نوع dynamic برای جلوگیری از import چرخشی

  GameCard({required this.suit, required this.rank});

  String get suitName => suit.suitName;
  String get suitSymbol => suit.suitSymbol;
  String get rankName => rank.rankName;

  String get imagePath {
    String rankStr = rank.toString().split('.').last;
    String suitChar =
        suit.toString().split('.').last[0]; // Get first character of suit
    return 'assets/images/$rankStr$suitChar.png';
  }

  @override
  String toString() {
    return '$rankName $suitName';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameCard &&
          runtimeType == other.runtimeType &&
          suit == other.suit &&
          rank == other.rank;

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;
}
