import 'package:get/get.dart';
import 'package:persian_hokm/game/models/card.dart';

/// مدیریت وضعیت‌های مختلف بازی
class GameStateManager {
  /// مقداردهی اولیه وضعیت بازی
  static void initializeGameState({
    required RxMap<String, RxList<GameCard>> playerCards,
    required RxMap<String, RxInt> teamScores,
    required RxMap<String, RxInt> teamSets,
    required Rxn hokmPlayer,
    required RxBool showCards,
    required RxBool showStartButton,
    required RxBool showTajAndCircle,
    required Rxn selectedHokm,
    required RxBool showHokmDialog,
    required RxBool isFirstDistributionDone,
    required RxBool isSecondDistributionDone,
    required RxBool isThirdDistributionDone,
    required RxMap<String, RxDouble> cardPositions,
    required List<GameCard> cards,
    required List<GameCard> deck,
    required List<List<GameCard>> hands,
    required List<dynamic> animatedPlayedCards,
    required Rxn firstSuit,
  }) {
    for (var list in playerCards.values) {
      list.clear();
    }
    teamScores['team1']?.value = 0;
    teamScores['team2']?.value = 0;
    teamSets['team1']?.value = 0;
    teamSets['team2']?.value = 0;
    hokmPlayer.value = '';
    showCards.value = false;
    showStartButton.value = true;
    showTajAndCircle.value = false;
    selectedHokm.value = null;
    showHokmDialog.value = false;
    isFirstDistributionDone.value = false;
    isSecondDistributionDone.value = false;
    isThirdDistributionDone.value = false;
    cardPositions['left']?.value = 0.0;
    cardPositions['right']?.value = 0.0;
    cardPositions['top']?.value = 0.0;
    cards.clear();
    deck.clear();
    for (var h in hands) {
      h.clear();
    }
    animatedPlayedCards.clear();
    firstSuit.value = null;
  }
}
