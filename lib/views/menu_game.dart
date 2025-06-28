import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sockets/colors.dart';
import 'package:sockets/cells.dart';
import 'package:sockets/model/model.dart';
import 'package:sockets/sucesos/event.dart';
import 'package:sockets/sucesos/moment.dart';
import 'package:sockets/game.dart';
import 'package:sockets/network/client.dart';

class Gamemenu extends StatelessWidget {
  static const routeName = '/game';

  final GameConfiguration configuration;
  final String serverAddress;
  final int serverPort;

  const Gamemenu({
    super.key,
    required this.configuration,
    required this.serverAddress,
    required this.serverPort,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final socket = WebSocketClient();
        final url = 'ws://$serverAddress:$serverPort';
        socket.connect(url);
        final bloc = GameBloc(configuration, socket);
        bloc.add(const InitGame());
        return bloc;
      },
      child: BlocBuilder<GameBloc, Gamemoment>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('MineSweeper'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<GameBloc>().socket.sendRestart();
                  },
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.topCenter,
                  colors: [kBackgroundStartColor, kBackgroundEndColor],
                ),
              ),
              child: _getContent(state, context),
            ),
          );
        },
      ),
    );
  }

  Widget _getContent(Gamemoment state, BuildContext context) {
    if (state is Playing) {
      return _gameContent(
        context,
        state.gameConfiguration,
        state.cells,
        state.minesRemaining,
        state.timeElapsed,
        false,
      );
    } else if (state is Finished) {
      return _gameContent(
        context,
        state.gameConfiguration,
        state.cells,
        state.minesRemaining,
        state.timeElapsed,
        state.isWinner,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _gameContent(
    BuildContext context,
    GameConfiguration configuration,
    List<Cell> cells,
    int minesRemaining,
    int timeElapsed,
    bool isWinner,
  ) {
    final socket = context.read<GameBloc>().socket;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                timeElapsed.toString(),
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
              const Spacer(),
              Text(
                minesRemaining.toString(),
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: configuration.width,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: CellView(
                  key: ObjectKey(cells[index]),
                  cell: cells[index],
                  onClick: () => socket.sendClick(index),
                  onLongPress: () => socket.sendFlag(index),
                ),
              );
            },
          ),
        ),
        if (isWinner)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              '🎉 CONGRATULATIONS 🎉',
              style: Theme.of(context).primaryTextTheme.headlineMedium,
            ),
          ),
      ],
    );
  }
}