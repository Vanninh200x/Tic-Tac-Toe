import 'dart:convert';
import 'game_enums.dart';

class GameHistoryEntry {
  final String id;
  final GameMode mode;
  final int boardSize;
  final int winLength;
  final PlayerType? winner; // null if draw
  final int totalMoves;
  final int durationSeconds;
  final DateTime playedAt;

  const GameHistoryEntry({
    required this.id,
    required this.mode,
    required this.boardSize,
    required this.winLength,
    required this.winner,
    required this.totalMoves,
    required this.durationSeconds,
    required this.playedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mode': mode.name,
        'boardSize': boardSize,
        'winLength': winLength,
        'winner': winner?.name,
        'totalMoves': totalMoves,
        'durationSeconds': durationSeconds,
        'playedAt': playedAt.toIso8601String(),
      };

  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) =>
      GameHistoryEntry(
        id: json['id'] as String,
        mode: GameMode.values.byName(json['mode'] as String),
        boardSize: json['boardSize'] as int,
        winLength: json['winLength'] as int,
        winner: json['winner'] != null
            ? PlayerType.values.byName(json['winner'] as String)
            : null,
        totalMoves: json['totalMoves'] as int,
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}

class GameStats {
  final int totalGames;
  final int xWins;
  final int oWins;
  final int draws;
  final int vsAiWins;
  final int vsAiLosses;
  final List<GameHistoryEntry> history;

  const GameStats({
    this.totalGames = 0,
    this.xWins = 0,
    this.oWins = 0,
    this.draws = 0,
    this.vsAiWins = 0,
    this.vsAiLosses = 0,
    this.history = const [],
  });

  double get winRatePercent {
    if (totalGames == 0) return 0;
    return (xWins / totalGames) * 100;
  }

  GameStats copyWith({
    int? totalGames,
    int? xWins,
    int? oWins,
    int? draws,
    int? vsAiWins,
    int? vsAiLosses,
    List<GameHistoryEntry>? history,
  }) {
    return GameStats(
      totalGames: totalGames ?? this.totalGames,
      xWins: xWins ?? this.xWins,
      oWins: oWins ?? this.oWins,
      draws: draws ?? this.draws,
      vsAiWins: vsAiWins ?? this.vsAiWins,
      vsAiLosses: vsAiLosses ?? this.vsAiLosses,
      history: history ?? this.history,
    );
  }

  Map<String, dynamic> toMap() => {
        'totalGames': totalGames,
        'xWins': xWins,
        'oWins': oWins,
        'draws': draws,
        'vsAiWins': vsAiWins,
        'vsAiLosses': vsAiLosses,
        'history': history.map((e) => e.toJson()).toList(),
      };

  String toJson() => jsonEncode(toMap());

  factory GameStats.fromMap(Map<String, dynamic> map) {
    return GameStats(
      totalGames: map['totalGames'] as int? ?? 0,
      xWins: map['xWins'] as int? ?? 0,
      oWins: map['oWins'] as int? ?? 0,
      draws: map['draws'] as int? ?? 0,
      vsAiWins: map['vsAiWins'] as int? ?? 0,
      vsAiLosses: map['vsAiLosses'] as int? ?? 0,
      history: (map['history'] as List<dynamic>? ?? [])
          .map((item) => GameHistoryEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory GameStats.fromJson(String source) =>
      GameStats.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
