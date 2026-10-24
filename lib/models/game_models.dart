import 'package:flutter/foundation.dart';
import 'game_enums.dart';

@immutable
class CellCoord {
  final int row;
  final int col;

  const CellCoord(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellCoord &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'CellCoord($row, $col)';
}

class WinResult {
  final PlayerType winner;
  final List<CellCoord> winningCells;
  final WinDirection direction;

  const WinResult({
    required this.winner,
    required this.winningCells,
    required this.direction,
  });

  bool contains(CellCoord coord) => winningCells.contains(coord);
}

class MoveRecord {
  final CellCoord coord;
  final PlayerType player;
  final DateTime timestamp;
  final int moveNumber;

  const MoveRecord({
    required this.coord,
    required this.player,
    required this.timestamp,
    required this.moveNumber,
  });

  Map<String, dynamic> toJson() => {
        'row': coord.row,
        'col': coord.col,
        'player': player.name,
        'timestamp': timestamp.toIso8601String(),
        'moveNumber': moveNumber,
      };

  factory MoveRecord.fromJson(Map<String, dynamic> json) => MoveRecord(
        coord: CellCoord(json['row'] as int, json['col'] as int),
        player: PlayerType.values.byName(json['player'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        moveNumber: json['moveNumber'] as int,
      );
}

class GameConfig {
  final int boardSize;
  final int winLength;
  final GameMode mode;
  final AIDifficulty aiDifficulty;
  final PlayerType humanPlayer;
  final PlayerType firstPlayer;
  final bool blockedEndsRule;
  final int timeLimitSeconds; // 0 = unlimited

  const GameConfig({
    this.boardSize = 3,
    this.winLength = 3,
    this.mode = GameMode.vsAI,
    this.aiDifficulty = AIDifficulty.master,
    this.humanPlayer = PlayerType.x,
    this.firstPlayer = PlayerType.x,
    this.blockedEndsRule = false,
    this.timeLimitSeconds = 0,
  });

  GameConfig copyWith({
    int? boardSize,
    int? winLength,
    GameMode? mode,
    AIDifficulty? aiDifficulty,
    PlayerType? humanPlayer,
    PlayerType? firstPlayer,
    bool? blockedEndsRule,
    int? timeLimitSeconds,
  }) {
    return GameConfig(
      boardSize: boardSize ?? this.boardSize,
      winLength: winLength ?? this.winLength,
      mode: mode ?? this.mode,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      humanPlayer: humanPlayer ?? this.humanPlayer,
      firstPlayer: firstPlayer ?? this.firstPlayer,
      blockedEndsRule: blockedEndsRule ?? this.blockedEndsRule,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
    );
  }
}
