import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sockets/colors.dart';
import 'package:sockets/sockets.dart'; 
import 'package:sockets/model/model.dart';
import 'package:sockets/cells.dart';
import 'package:sockets/sucesos/event.dart';
import 'package:sockets/sucesos/moment.dart';

class Gamemenu extends StatelessWidget {
  static const routeName = '/game';
  static const configurationKey = 'configuration';

  final GameConfiguration configuration;

  const Gamemenu({super.key, required this.configuration});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(configuration)..add(const InitGame()),
      child: BlocBuilder<GameBloc, Gamemoment>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('MineSweeper'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<GameBloc>().add(const InitGame());
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
    return _loading();
  }

  Widget _loading() {
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
    final bloc = context.read<GameBloc>();
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
                  onLongPress: () => bloc.add(LongClicked(index)),
                  onClick: () => bloc.add(Click(index)),
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