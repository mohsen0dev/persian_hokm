import 'package:as_hokme/game/models/enums.dart';
import 'package:as_hokme/game/models/player.dart';
import 'package:as_hokme/game/models/team.dart';
import 'package:as_hokme/game/models/card.dart';

/// مدیریت ساخت و مقداردهی اولیه بازیکنان و تیم‌ها
class PlayerTeamManager {
  /// ساخت لیست بازیکنان و تیم‌ها بر اساس سطح هوش مصنوعی و دست‌ها
  static Map<String, dynamic> createPlayersAndTeams({
    required int aiLevel,
    required List<List<GameCard>> hands,
  }) {
    final players = [
      PlayerHuman('شما', hands[Direction.bottom.index], Direction.bottom),
      PlayerAI('حریف1', Direction.right, hands[Direction.right.index],
          aiLevel: aiLevel, isPartner: false),
      PlayerAI('یار شما', Direction.top, hands[Direction.top.index],
          aiLevel: aiLevel, isPartner: true),
      PlayerAI('حریف2', Direction.left, hands[Direction.left.index],
          aiLevel: aiLevel, isPartner: false),
    ];
    final teams = [
      Team(players[0], players[2]),
      Team(players[1], players[3]),
    ];
    players[0].team = teams[0];
    players[2].team = teams[0];
    players[1].team = teams[1];
    players[3].team = teams[1];
    return {
      'players': players,
      'teams': teams,
    };
  }
}
