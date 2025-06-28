import 'dart:convert';
import 'dart:io';
import 'dart:async';

final List<WebSocket> _clients = [];
final Map<WebSocket, int> _playerIds = {};
int _currentPlayer = 1;
void main() async {
  await startserver();
}
Future<void> startserver() async {
  final ip = await _getLocalIP();

  if (ip == null) {
    print('⚠️ No se pudo obtener la IP local.');
    return;
  }

  stdout.write('🔌 Puerto (enter para automático): ');
  final input = stdin.readLineSync();
  final port = (input == null || input.isEmpty)
      ? await _findFreePort()
      : int.tryParse(input) ?? await _findFreePort();

  final server = await HttpServer.bind(ip, port);
  print('✅ Servidor WebSocket en: ws://$ip:$port');

  await for (HttpRequest request in server) {
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final socket = await WebSocketTransformer.upgrade(request);
      if (_clients.length >= 2) {
        socket.add(jsonEncode({'type': 'error', 'msg': 'Sala llena'}));
        socket.close();
        continue;
      }

      _clients.add(socket);
      _playerIds[socket] = _clients.length;
      print('🎮 Cliente ${_playerIds[socket]} conectado');

      socket.listen(
        (data) => _handleMessage(socket, data),
        onDone: () {
          print('👋 Cliente ${_playerIds[socket]} desconectado');
          _clients.remove(socket);
          _playerIds.remove(socket);
        },
      );

      _broadcast(jsonEncode({
        'type': 'player_join',
        'players': _playerIds.values.toList(),
        'currentPlayer': _currentPlayer
      }));
    } else {
      request.response
        ..statusCode = HttpStatus.forbidden
        ..close();
    }
  }
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

void _handleMessage(WebSocket sender, String data) {
  final player = _playerIds[sender];
  final msg = jsonDecode(data);

  if (player != _currentPlayer) {
    sender.add(jsonEncode({
      'type': 'error',
      'msg': 'No es tu turno',
    }));
    return;
  }

  switch (msg['type']) {
    case 'click':
    case 'flag':
      _broadcast(jsonEncode({
        'type': msg['type'],
        'index': msg['index'],
        'player': player,
      }));
      _switchTurn();
      break;
    case 'restart':
      _broadcast(jsonEncode({'type': 'restart'}));
      _currentPlayer = 1;
      break;
    default:
      sender.add(jsonEncode({'type': 'error', 'msg': 'Acción desconocida'}));
  }
}

void _broadcast(String data) {
  for (final client in _clients) {
    client.add(data);
  }
}

void _switchTurn() {
  _currentPlayer = _currentPlayer == 1 ? 2 : 1;
  _broadcast(jsonEncode({'type': 'turn', 'currentPlayer': _currentPlayer}));
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
  throw Exception('❌ No se encontró un puerto disponible entre 8000 y 8100.');
}
