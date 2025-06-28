import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:sockets/model/model.dart';
import 'package:sockets/sucesos/event.dart';
import 'package:sockets/sucesos/moment.dart';
import 'package:sockets/network/client.dart'; 

class GameBloc extends Bloc<Event, Gamemoment> {
  final GameConfiguration configuration;
  final WebSocketClient socket;

  Timer? _timer;
  int _time = 0;

  GameBloc(this.configuration, this.socket) : super(GameInitial(configuration)) {
    // Escucha mensajes del servidor
    socket.onServerEvent = (type, msg) {
      switch (type) {
        case 'click':
          add(Click(msg['index']));
          break;
        case 'flag':
          add(LongClicked(msg['index']));
          break;
        case 'restart':
          add(InitGame());
          break;
      }
    };

    on<InitGame>(_onInitGame);
    on<Click>(_onClick);
    on<LongClicked>(_onLongClick);
    on<TimeTick>(_onTimeTick);
  }

  void _onInitGame(InitGame event, Emitter<Gamemoment> emit) {
    final List<Cell> cells = _generateCells(configuration.width, configuration.height, configuration.mines);
    _time = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(TimeTick()));

    emit(Playing(
      configuration: configuration,
      cells: cells,
      minesRemaining: configuration.mines,
      timeElapsed: _time,
    ));
  }

  void _onTimeTick(TimeTick event, Emitter<Gamemoment> emit) {
    if (state is! Playing) return;
    final current = state as Playing;
    emit(Playing(
      configuration: current.gameConfiguration,
      cells: current.cells,
      minesRemaining: current.minesRemaining,
      timeElapsed: _time++,
    ));
  }

  void _onClick(Click event, Emitter<Gamemoment> emit) {
    if (state is! Playing) return;
    final current = state as Playing;
    final cell = current.cells[event.index];
    if (cell is! CellClose || cell.isFlagged) return;

    if (cell.content == CellCont.bomb) {
      _timer?.cancel();
      emit(Finished(
        configuration: current.gameConfiguration,
        cells: _revealAll(current.cells),
        minesRemaining: current.minesRemaining,
        isWinner: false,
        timeElapsed: _time,
      ));
      return;
    }

    final newCells = [...current.cells];
    final revealed = _revealArea(event.index, newCells, current.gameConfiguration);
    final hasWon = _checkIfWon(revealed, current.gameConfiguration.mines);

    if (hasWon) {
      _timer?.cancel();
      emit(Finished(
        configuration: current.gameConfiguration,
        cells: revealed,
        minesRemaining: 0,
        isWinner: true,
        timeElapsed: _time,
      ));
    } else {
      emit(Playing(
        configuration: current.gameConfiguration,
        cells: revealed,
        minesRemaining: current.minesRemaining,
        timeElapsed: _time,
      ));
    }
  }

  void _onLongClick(LongClicked event, Emitter<Gamemoment> emit) {
    if (state is! Playing) return;
    final current = state as Playing;
    final cell = current.cells[event.index];
    if (cell is! CellClose) return;

    final updated = CellClose(
      content: cell.content,
      isFlagged: !cell.isFlagged,
    );

    final newCells = [...current.cells];
    newCells[event.index] = updated;

    final delta = updated.isFlagged ? -1 : 1;
    emit(Playing(
      configuration: current.gameConfiguration,
      cells: newCells,
      minesRemaining: current.minesRemaining + delta,
      timeElapsed: _time,
    ));
  }

  List<Cell> _generateCells(int width, int height, int mines) {
    final total = width * height;
    final random = Random();
    final positions = <int>{};

    while (positions.length < mines) {
      positions.add(random.nextInt(total));
    }

    final cells = List.generate(total, (index) {
      final isBomb = positions.contains(index);
      return CellClose(
        content: isBomb ? CellCont.bomb : CellCont.zero,
        isFlagged: false,
      );
    });

    _setNeighborNumbers(cells, width, height);
    return cells;
  }

  void _setNeighborNumbers(List<Cell> cells, int width, int height) {
    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i];
      if (cell.content == CellCont.bomb) continue;

      int row = i ~/ width;
      int col = i % width;
      int count = 0;

      for (int r = row - 1; r <= row + 1; r++) {
        for (int c = col - 1; c <= col + 1; c++) {
          if (r < 0 || r >= height || c < 0 || c >= width) continue;
          final idx = r * width + c;
          if (cells[idx].content == CellCont.bomb) count++;
        }
      }

      cells[i] = CellClose(
        content: CellCont.values[count],
        isFlagged: (cell as CellClose).isFlagged,
      );
    }
  }

  List<Cell> _revealArea(int startIndex, List<Cell> cells, GameConfiguration config) {
    final width = config.width;
    final height = config.height;
    final visited = <int>{};
    final queue = Queue<int>()..add(startIndex);

    while (queue.isNotEmpty) {
      final index = queue.removeFirst();
      if (visited.contains(index)) continue;
      visited.add(index);

      final cell = cells[index];
      if (cell is! CellClose || cell.isFlagged) continue;

      cells[index] = CellOpen(content: cell.content);

      if (cell.content == CellCont.zero) {
        final row = index ~/ width;
        final col = index % width;

        for (int r = row - 1; r <= row + 1; r++) {
          for (int c = col - 1; c <= col + 1; c++) {
            if (r < 0 || r >= height || c < 0 || c >= width) continue;
            final neighborIndex = r * width + c;
            if (!visited.contains(neighborIndex)) {
              queue.add(neighborIndex);
            }
          }
        }
      }
    }

    return cells;
  }

  List<Cell> _revealAll(List<Cell> cells) {
    return cells.map((cell) {
      if (cell is CellClose) {
        return CellOpen(content: cell.content);
      }
      return cell;
    }).toList();
  }

  bool _checkIfWon(List<Cell> cells, int totalMines) {
    final opened = cells.whereType<CellOpen>().length;
    return opened == cells.length - totalMines;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    socket.close();
    return super.close();
  }
}