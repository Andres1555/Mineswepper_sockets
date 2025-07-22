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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
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
    showDialog(
      context: context,
      builder: (_) => const _HostDialog(),
    );
  }

  void _onJoinGameClicked(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _JoinDialog(),
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

    final config = GameConfiguration(width: 16, height: 16, mines: 40);
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

class _HostDialog extends StatefulWidget {
  const _HostDialog();

  @override
  State<_HostDialog> createState() => _HostDialogState();
}

class _HostDialogState extends State<_HostDialog> {
  final ipController = TextEditingController();
  final portController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _infoMsg;
  bool _loading = false;
  String? _finalIp;
  int? _finalPort;

  // Dificultad
  String _difficulty = 'facil';
  int _customWidth = 10;
  int _customHeight = 10;
  int _customMines = 15;

  GameConfiguration get _config {
    switch (_difficulty) {
      case 'facil':
        return GameConfiguration(width: 10, height: 10, mines: 15);
      case 'medio':
        return GameConfiguration(width: 15, height: 15, mines: 50);
      case 'personalizado':
        return GameConfiguration(
          width: _customWidth.clamp(5, 18),
          height: _customHeight.clamp(5, 18),
          mines: _customMines,
        );
      default:
        return GameConfiguration(width: 10, height: 10, mines: 15);
    }
  }

  Future<void> _startHost() async {
    setState(() { _loading = true; _infoMsg = null; });
    String? ip = ipController.text.trim().isEmpty ? await _getLocalIP() : ipController.text.trim();
    int? port = portController.text.trim().isEmpty ? await _findFreePort() : int.tryParse(portController.text.trim());
    if (ip == null || port == null) {
      setState(() { _infoMsg = 'No se pudo obtener IP o puerto.'; _loading = false; });
      return;
    }
    setState(() {
      _finalIp = ip;
      _finalPort = port;
      _infoMsg = 'Servidor iniciado en:\nIP: $ip\nPuerto: $port';
      _loading = false;
    });
  }

  void _goToGame() {
    if (_finalIp == null || _finalPort == null) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Gamemenu(
          configuration: _config,
          serverAddress: _finalIp!,
          serverPort: _finalPort!,
          isHost: true,
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
        'Crear partida (Host)',
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
            DropdownButtonFormField<String>(
              value: _difficulty,
              dropdownColor: Colors.black87,
              decoration: const InputDecoration(
                labelText: 'Dificultad',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
              items: const [
                DropdownMenuItem(value: 'facil', child: Text('Fácil', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'medio', child: Text('Medio', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'personalizado', child: Text('Personalizado', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (v) => setState(() => _difficulty = v ?? 'facil'),
            ),
            if (_difficulty == 'personalizado') ...[
              const SizedBox(height: 8),
              TextFormField(
                initialValue: '10',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontFamily: 'yoster', fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'Ancho ',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
                onChanged: (v) => _customWidth = int.tryParse(v) ?? 10,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: '10',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontFamily: 'yoster', fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'Alto',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
                onChanged: (v) => _customHeight = int.tryParse(v) ?? 10,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: '15',
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontFamily: 'yoster', fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'Minas',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                ),
                onChanged: (v) => _customMines = int.tryParse(v) ?? 15,
              ),
            ],
            const SizedBox(height: 8),
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
                labelText: 'Puerto ',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
              ),
            ),
            if (_infoMsg != null) ...[
              const SizedBox(height: 16),
              Text(_infoMsg!, style: const TextStyle(color: Colors.white, fontFamily: 'yoster', fontSize: 13)),
            ],
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
        if (_infoMsg == null)
          ElevatedButton(
            onPressed: _loading ? null : _startHost,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(
                    'Iniciar',
                    style: TextStyle(
                      fontFamily: 'yoster',
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
          ),
        if (_infoMsg != null)
          ElevatedButton(
            onPressed: _goToGame,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text(
              'OK',
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

  Future<String?> _getLocalIP() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return null;
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
    return 8080;
  }
}