import 'dart:convert';
import 'dart:io';

class WebSocketClient {
  late WebSocket _socket;
  bool _connected = false;
  Function(String type, Map<String, dynamic> msg)? onServerEvent;
  int? receivedSeed;
  int? currentTurn;
  int? receivedWidth;
  int? receivedHeight;
  int? receivedMines;

  WebSocketClient();

  Future<void> connect(String url) async {
    try {
      _socket = await WebSocket.connect(url);
      _connected = true;
      _socket.listen((data) {
        final msg = jsonDecode(data);
        if (msg is Map<String, dynamic>) {
          final type = msg['type'];
          if (type == 'seed') {
            receivedSeed = msg['seed'] as int;
            if (msg.containsKey('width') && msg.containsKey('height') && msg.containsKey('mines')) {
              receivedWidth = msg['width'] as int;
              receivedHeight = msg['height'] as int;
              receivedMines = msg['mines'] as int;
            }
          }
          if (type == 'turn') {
            currentTurn = msg['currentPlayer'];
          }
          onServerEvent?.call(type, msg);
        }
      }, onDone: () {
        _connected = false;
      });
    } catch (e) {
      rethrow;
    }
  }

  void sendClick(int index) {
    _send({'type': 'click', 'index': index});
  }

  void sendFlag(int index) {
    _send({'type': 'flag', 'index': index});
  }

  void sendRestart() {
    _send({'type': 'restart'});
  }

  void _send(Map<String, dynamic> msg) {
    if (_connected) {
      _socket.add(jsonEncode(msg));
    }
  }

  void close() {
    _socket.close();
  }
}