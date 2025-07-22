import 'package:sockets/model/model.dart';

abstract class Gamemoment {
  final GameConfiguration gameConfiguration;
  const Gamemoment(this.gameConfiguration);
}

class GameInitial extends Gamemoment {
  const GameInitial(super.gameConfiguration);
}

class Playing extends Gamemoment {
  final List<Cell> cells;
  final int minesRemaining;
  final int timeElapsed;
  const Playing({
    required GameConfiguration configuration,
    required this.cells,
    required this.minesRemaining,
    required this.timeElapsed,
  }) : super(configuration);
}

class Finished extends Gamemoment {
  final List<Cell> cells;
  final int minesRemaining;
  final bool isWinner;
  final int timeElapsed;
  final int? loserPlayer;
  final int? winnerPlayer;
  const Finished({
    required GameConfiguration configuration,
    required this.cells,
    required this.minesRemaining,
    required this.isWinner,
    required this.timeElapsed,
    this.loserPlayer,
    this.winnerPlayer,
  }) : super(configuration);
}