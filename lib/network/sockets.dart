import 'dart:convert';
import 'dart:io';
import 'dart:async';


final List<WebSocket> _clients = [];
final Map<WebSocket, int> _playerIds = {};
int _currentPlayer = 1;
WebSocket? _selfSocket;

/// Punto de entrada con parámetro isHost
Future<void> startGame({required bool isHost, String? hostAddress, int? port}) async {
  if (isHost) {
    final ip = await _getLocalIP();
    if (ip == null) {
      print('❌ No se pudo obtener la IP local.');
      return;
    }
    final realPort = port ?? await _findFreePort();
    // Inicia el servidor pero NO esperes a que haya clientes para enviar el tablero
    unawaited(_startServer(ip, realPort));
    await _connectAsClient('ws://$ip:$realPort');
    print('🟢 Host iniciado en ws://$ip:$realPort');
  } else {
    if (hostAddress == null) {
      print('❌ Dirección del host requerida para unirse.');
      return;
    }
    final uri = Uri.parse(hostAddress);
    final port = uri.hasPort ? uri.port : 8080;
    await _connectAsClient('ws://${uri.host}:$port');
  }
}

/// Inicia el servidor WebSocket
Future<void> _startServer(String ip, int port) async {
  final server = await HttpServer.bind(ip, port);
  print('Servidor WebSocket en: ws://$ip:$port');

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
          print('Cliente ${_playerIds[socket]} desconectado');
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

/// Conecta este mismo dispositivo como cliente
Future<void> _connectAsClient(String url) async {
  try {
    _selfSocket = await WebSocket.connect(url);
    print('✅ Conectado como jugador a $url');

    _selfSocket!.listen((data) {
      final msg = jsonDecode(data);
      if (msg is Map<String, dynamic>) {
        final type = msg['type'];
        print('📩 Evento recibido: $type → $msg');
      }
    }, onDone: () {
      print('🔌 Desconectado del servidor');
    });
  } catch (e) {
    print('❌ Error al conectar como cliente: $e');
  }
}

void sendClick(int index) => _send({'type': 'click', 'index': index});
void sendFlag(int index) => _send({'type': 'flag', 'index': index});
void sendRestart() => _send({'type': 'restart'});

void _send(Map<String, dynamic> msg) {
  if (_selfSocket?.readyState == WebSocket.open) {
    _selfSocket!.add(jsonEncode(msg));
  } else {
    print('⚠️ No conectado. Mensaje no enviado: $msg');
  }
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
  throw Exception('No se encontró un puerto disponible entre 8000 y 8100.');
}