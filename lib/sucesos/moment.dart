import 'package:sockets/model/model.dart';
import 'package:equatable/equatable.dart';

abstract class Gamemoment extends Equatable {
  final GameConfiguration gameConfiguration;

  const Gamemoment(this.gameConfiguration);

  @override
  List<Object> get props => [gameConfiguration];
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

  @override
  List<Object> get props => super.props
    ..add([
      cells,
      minesRemaining,
      timeElapsed,
    ]);
}

class Finished extends Gamemoment {
  final List<Cell> cells;
  final int minesRemaining;
  final bool isWinner;
  final int timeElapsed;

  const Finished({
    required GameConfiguration configuration,
    required this.cells,
    required this.minesRemaining,
    required this.isWinner,
    required this.timeElapsed,
  }) : super(configuration);

  @override
  List<Object> get props => super.props..add([cells, minesRemaining]);
}