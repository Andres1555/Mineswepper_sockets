import 'package:flutter/material.dart';
import 'package:sockets/views/menu.dart';
import 'package:sockets/views/menu_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MineSweeper',
      theme: ThemeData(
        fontFamily: 'Alucrads', 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: Menu.routeName,
      routes: {
        Menu.routeName: (context) => const Menu(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Gamemenu.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => Gamemenu(
              configuration: args['configuration'],
              serverAddress: args['serverAddress'],
              serverPort: args['serverPort'],
            ),
          );
        }
        return null;
      },
    );
  }
}