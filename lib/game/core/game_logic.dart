import 'package:get/get.dart';
import 'package:persian_hokm/game/models/card.dart';
import 'package:persian_hokm/game/presentation/pages/settings_screen.dart';
import 'package:persian_hokm/game/models/enums.dart';
import 'package:persian_hokm/game/models/player.dart';
import 'package:persian_hokm/game/models/team.dart';

/// کلاس اصلی منطق بازی حکم
class GameLogic {
  late List<GameCard> deck;
  late Direction hakem;
  late Direction tableDir;
  late Suit hokm;
  Direction directionHakemDetermination = Direction.bottom;
  List<List<GameCard>> hands = List.generate(4, (_) => []);
  List<Player> players = [];
  List<Team> teams = [];
  List<GameCard> table = [];
  List<List<GameCard>> tableHistory = [];
  int lastIndex = 52;
  late Direction starterDirection; // جهت شروع‌کننده هر دست

  GameLogic() {
    newGame();
  }

  //! ساخت یک بازی جدید
  void newGame() {
    for (var h in hands) {
      h.clear();
    }
    players.clear();
    teams.clear();
    table.clear();
    tableHistory.clear();
    deck = _getNewDeck();
    lastIndex = deck.length;
    // مقداردهی اولیه starterDirection (در صورت نیاز)
    starterDirection = Direction.bottom;
  }

  //! ساخت یک deck جدید
  List<GameCard> _getNewDeck() {
    final cards = <GameCard>[];
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        cards.add(GameCard(suit: suit, rank: rank));
      }
    }
    cards.shuffle();
    return cards;
  }

  //! متد عمومی برای گرفتن یک deck جدید (برای استفاده در UI)
  List<GameCard> getNewDeck() => _getNewDeck();

//! تعیین حاکم
  void determineHakem() {
    var card = deck.last;
    directionHakemDetermination = Direction.bottom;
    while (card.rank != Rank.ace) {
      deck.removeLast();
      if (deck.isEmpty) break;
      card = deck.last;
      directionHakemDetermination =
          _getNextDirection(directionHakemDetermination);
    }
    hakem = directionHakemDetermination;
    tableDir = directionHakemDetermination;
    starterDirection = directionHakemDetermination; // مقداردهی اولیه
    deck = _getNewDeck();
    lastIndex = deck.length;
  }

  //! متد خصوصی برای گرفتن جهت بعدی
  Direction _getNextDirection(Direction direction) {
    switch (direction) {
      case Direction.bottom:
        return Direction.right;
      case Direction.right:
        return Direction.top;
      case Direction.top:
        return Direction.left;
      case Direction.left:
        return Direction.bottom;
    }
  }

//! توزیع کارت
  void dealCards(int numCards) {
    var dir = hakem;
    for (int i = 0; i < 4; i++) {
      final cardsToDeal =
          deck.getRange(lastIndex - numCards, lastIndex).toList();
      hands[dir.index].addAll(cardsToDeal);
      if (players.length == 4) {
        for (var card in cardsToDeal) {
          card.player = players[dir.index];
        }
      }
      lastIndex -= numCards;
      dir = _getNextDirection(dir);
    }
    // ساخت بازیکنان و تیم‌ها فقط در اولین تقسیم کارت
    if (numCards == 5 && players.isEmpty) {
      final aiLevel = Get.find<SettingsController>().aiLevel.value;
      players = [
        PlayerHuman('شما', hands[Direction.bottom.index], Direction.bottom),
        PlayerAI('حریف1', Direction.right, hands[Direction.right.index],
            aiLevel: aiLevel, isPartner: false),
        PlayerAI('یار شما', Direction.top, hands[Direction.top.index],
            aiLevel: aiLevel, isPartner: true),
        PlayerAI('حریف2', Direction.left, hands[Direction.left.index],
            aiLevel: aiLevel, isPartner: false),
      ];
      teams = [
        Team(players[0], players[2]),
        Team(players[1], players[3]),
      ];
      players[0].team = teams[0];
      players[2].team = teams[0];
      players[1].team = teams[1];
      players[3].team = teams[1];
      for (int idx = 0; idx < 4; idx++) {
        for (var card in hands[idx]) {
          card.player = players[idx];
        }
      }
    } else {
      for (int i = 0; i < 4; i++) {
        players[i].addHand(hands[i]);
        for (var card in hands[i]) {
          card.player = players[i];
        }
      }
    }
  }

//! اعتبارسنجی کارت
  bool isValidCard(GameCard card, Direction playerDir) {
    if (tableDir != Direction.bottom) return false;
    if (table.isEmpty) return true;
    final hasSameSuit = players[Direction.bottom.index]
        .hand
        .any((c) => c.suit == table[0].suit);
    if (!hasSameSuit) return true;
    if (table[0].suit == card.suit) return true;
    return false;
  }

//! بازی کردن کارت
  void playCard(GameCard card, Direction direction) {
    // حذف کارت از دست بازیکن (در منطق بازی)
    players[direction.index]
        .hand
        .removeWhere((c) => c.suit == card.suit && c.rank == card.rank);
    card.player = players[direction.index]; // اطمینان از مقداردهی درست
    table.add(card);
    tableDir = _getNextDirection(direction);
    if (table.length == 4) {
      final winner = getTableWinner(table, hokm, teams);
      winner.team.score++;
      tableDir = winner.direction;
      starterDirection = winner.direction; // مقداردهی جهت شروع‌کننده دست بعدی
      tableHistory.add(List.from(table));
      // به‌روزرسانی آخرین خال بازی‌شده توسط یار برای هر بازیکن
      if (players.length == 4) {
        final lastHand = tableHistory.last;
        int starterIdx =
            players.indexWhere((p) => p.direction == starterDirection);
        for (int i = 0; i < 4; i++) {
          final player = players[i];
          // پیدا کردن یار (هم‌تیمی)
          final partner = player.team.playerA == player
              ? player.team.playerB
              : player.team.playerA;
          // موقعیت یار در دست
          int partnerOffset = players.indexOf(partner);
          final partnerCard = lastHand[partnerOffset];
          // فقط اگر یار نفر اول دست قبلی بوده
          if (partnerOffset == starterIdx) {
            player.updateLastPartnerSuit(partnerCard.suit);
          }
        }
      }
      table.clear();
    }
  }

//! بازیکن برنده
  Player getTableWinner(List<GameCard> table, Suit hokm, List<Team> teams) {
    // اگر همه کارت‌ها هم‌خال باشند
    if (table.every((c) => c.suit == table[0].suit)) {
      return _getWinner(table);
    } else {
      // اگر حکم داری
      final hokmCards = table.where((c) => c.suit == hokm).toList();
      if (hokmCards.isNotEmpty) {
        return _getWinner(hokmCards);
      } else {
        // اگر حکم نداری
        final sameSuitAsFirst =
            table.where((c) => c.suit == table[0].suit).toList();
        return _getWinner(sameSuitAsFirst);
      }
    }
  }

//! بازیکن برنده
  Player _getWinner(List<GameCard> cards) {
    // کارت با بالاترین ارزش (index کمتر یعنی ارزش بیشتر)
    GameCard winnerCard = cards.first;
    for (var card in cards) {
      if (card.rank.index < winnerCard.rank.index) {
        winnerCard = card;
      }
    }
    return winnerCard.player!;
  }
}
