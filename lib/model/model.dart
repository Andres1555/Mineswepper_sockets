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

class Cell {
  final CellCont content;
  const Cell({required this.content});
}

class CellClose extends Cell {
  final bool isFlagged;
  const CellClose({required super.content, this.isFlagged = false});
}

class CellOpen extends Cell {
  const CellOpen({required super.content});
}

class GameConfiguration {
  final int width;
  final int height;
  final int mines;
  GameConfiguration({required this.width, required this.height, required this.mines});
}