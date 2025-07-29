import 'package:get/get.dart';
import 'package:persian_hokm/game/models/enums.dart';

/// مدیریت امتیازدهی و پایان ست/بازی
class GameScoreManager {
  final RxMap<String, RxInt> teamScores;
  final RxMap<String, RxInt> teamSets;
  final RxList<int> team1WonHands;
  final RxList<int> team2WonHands;

  GameScoreManager({
    required this.teamScores,
    required this.teamSets,
    required this.team1WonHands,
    required this.team2WonHands,
  });

  /// افزایش امتیاز تیم برنده دست
  void increaseHandScore(String winner) {
    if (winner == 'bottom' || winner == 'top') {
      teamScores['team1']?.value++;
      team1WonHands.add(1);
    } else {
      teamScores['team2']?.value++;
      team2WonHands.add(1);
    }
  }

  /// بررسی پایان ست
  bool isSetFinished() {
    return teamScores['team1']?.value == 7 || teamScores['team2']?.value == 7;
  }

  /// افزایش امتیاز ست و ریست امتیاز دست‌ها
  /// اگر یک تیم ۷-۰ ست را ببرد، امتیاز ست به جای ۱ برابر ۲ می‌شود و اگر تیم مقابل حاکم باشد، امتیاز ست برابر ۳ می‌شود
  String finishSet({required Direction currentHakemDir}) {
    String winningTeam;
    int team1Score = teamScores['team1']?.value ?? 0;
    int team2Score = teamScores['team2']?.value ?? 0;
    // تعیین تیم حاکم
    // team1: bottom/top  |  team2: right/left
    bool hakemIsTeam1 = (currentHakemDir == Direction.bottom ||
        currentHakemDir == Direction.top);
    if (team1Score == 7) {
      // اگر تیم ۱ با نتیجه ۷-۰ برده باشد
      if (team2Score == 0) {
        if (!hakemIsTeam1) {
          teamSets['team1']?.value += 3;
        } else {
          teamSets['team1']?.value += 2;
        }
      } else {
        teamSets['team1']?.value++;
      }
      winningTeam = 'team1';
    } else {
      // اگر تیم ۲ با نتیجه ۷-۰ برده باشد
      if (team1Score == 0) {
        if (hakemIsTeam1) {
          teamSets['team2']?.value += 3;
        } else {
          teamSets['team2']?.value += 2;
        }
      } else {
        teamSets['team2']?.value++;
      }
      winningTeam = 'team2';
    }
    teamScores['team1']?.value = 0;
    teamScores['team2']?.value = 0;
    team1WonHands.clear();
    team2WonHands.clear();
    return winningTeam;
  }

  /// بررسی پایان بازی
  bool isGameFinished() {
    return (teamSets['team1']?.value ?? 0) >= 7 ||
        (teamSets['team2']?.value ?? 0) >= 7;
  }

  /// تعیین تیم برنده نهایی
  String getFinalWinner() {
    if ((teamSets['team1']?.value ?? 0) >= 7) {
      return 'team1';
    } else if ((teamSets['team2']?.value ?? 0) >= 7) {
      return 'team2';
    }
    return '';
  }
}
