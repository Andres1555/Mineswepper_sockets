import 'package:flutter/material.dart';
import 'package:sockets/model/model.dart';
import 'menu_game.dart';

class Menu extends StatelessWidget {
  static const routeName = '/';

  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MineSweeper'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
              ),
              child: Text('HOST GAME'),
              onPressed: () => _onHostGameClicked(context),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
              ),
              child: Text('JOIN GAME'),
              onPressed: () => _onJoinGameClicked(context),
            ),
          ],
        ),
      ),
    );
  }

  void _onHostGameClicked(BuildContext context) {
    final configuration = GameConfiguration(
      width: 10,
      height: 10,
      mines: 15,
    );

    // Aquí podrías iniciar el servidor de sockets antes de navegar
    _navigateToGame(context, configuration);
  }

  void _onJoinGameClicked(BuildContext context) {
    // Aquí podrías mostrar un diálogo para ingresar IP/puerto del host
    final configuration = GameConfiguration(
      width: 10,
      height: 10,
      mines: 15,
    );

    _navigateToGame(context, configuration);
  }

  void _navigateToGame(BuildContext context, GameConfiguration configuration) {
    Navigator.pushNamed(
      context,
      Gamemenu.routeName,
      arguments: configuration,
    );
  }
}