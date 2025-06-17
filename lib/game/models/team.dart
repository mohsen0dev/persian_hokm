import 'package:persian_hokm/game/models/player.dart'; // Will be created/updated

/// تیم (دو بازیکن)
class Team {
  final Player playerA;
  final Player playerB;
  int score = 0;
  Team(this.playerA, this.playerB);
}
