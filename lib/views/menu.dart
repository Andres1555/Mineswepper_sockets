import 'dart:io';
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
        title: const Text(
          'MineSweeper',
          style: TextStyle(
            fontFamily: 'yoster',
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/descarga.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PixelButton(
                    label: 'HOST GAME',
                    onPressed: () => _onHostGameClicked(context),
                  ),
                  const SizedBox(height: 32),
                  PixelButton(
                    label: 'JOIN GAME',
                    onPressed: () => _onJoinGameClicked(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onHostGameClicked(BuildContext context) async {
    final config = GameConfiguration(width: 10, height: 10, mines: 15);
    final ip = await _getLocalIP();
    int port = await _findFreePort();

    if (ip == null) {
      _showError(context, 'No se pudo obtener la IP local.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Gamemenu(
          configuration: config,
          serverAddress: ip,
          serverPort: port,
          isHost: true,
        ),
      ),
    );
  }

  Future<int> _findFreePort() async {
    for (int port = 8000; port < 8100; port++) {
      try {
        final test = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        await test.close();
        return port;
      } catch (_) {
        continue;
      }
    }
    return 8080; // fallback
  }

  void _onJoinGameClicked(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _JoinDialog(),
    );
  }

  Future<String?> _getLocalIP() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return null;
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PixelButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 36),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'yoster',
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _JoinDialog extends StatefulWidget {
  const _JoinDialog();

  @override
  State<_JoinDialog> createState() => _JoinDialogState();
}

class _JoinDialogState extends State<_JoinDialog> {
  final ipController = TextEditingController();
  final portController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _join() {
    if (!_formKey.currentState!.validate()) return;
    final ip = ipController.text;
    final port = int.tryParse(portController.text);
    if (port == null) return;

    final config = GameConfiguration(width: 10, height: 10, mines: 15);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Gamemenu(
          configuration: config,
          serverAddress: ip,
          serverPort: port,
          isHost: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      title: const Text(
        'Conectarse al host',
        style: TextStyle(
          fontFamily: 'yoster',
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: ipController,
              style: const TextStyle(
                fontFamily: 'yoster',
                fontSize: 12,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelText: 'Dirección IP',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: portController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: 'yoster',
                fontSize: 12,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                labelText: 'Puerto',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              fontFamily: 'yoster',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _join,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          child: const Text(
            'Conectar',
            style: TextStyle(
              fontFamily: 'yoster',
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}