import 'package:equatable/equatable.dart';


enum CellCont {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  bomb,
}

abstract class Cell extends Equatable {
  final CellCont content;

  const Cell({
    required this.content,
  });

  @override
  List<Object> get props => [content];
}

class CellClose extends Cell {
  final bool isFlagged;

  const CellClose({
    required super.content,
    this.isFlagged = false,
  });

  @override
  List<Object> get props => super.props..add(isFlagged);
}

class CellOpen extends Cell {
  const CellOpen({
    required super.content,
  });
}

class GameConfiguration {
  final int width;
  final int height;
  final int mines;

  GameConfiguration({
    required this.width,
    required this.height,
    required this.mines,
  });
}