class GameStats {
  final int aiWins;
  final int aiLosses;
  final int aiDraws;
  final int playerXWins;
  final int playerOWins;
  final int twoPlayerDraws;

  const GameStats({
    this.aiWins = 0,
    this.aiLosses = 0,
    this.aiDraws = 0,
    this.playerXWins = 0,
    this.playerOWins = 0,
    this.twoPlayerDraws = 0,
  });

  int get totalGames => aiWins + aiLosses + aiDraws + playerXWins + playerOWins + twoPlayerDraws;
  int get aiGames => aiWins + aiLosses + aiDraws;
  int get twoPlayerGames => playerXWins + playerOWins + twoPlayerDraws;
}
