import 'dart:convert';
import 'dart:io';


typedef OnServerEvent = void Function(String type, Map<String, dynamic> msg);

class WebSocketClient {
  late WebSocket _socket;
  bool _connected = false;
  OnServerEvent? onServerEvent; // ← ya no es final

  WebSocketClient();

  Future<void> connect(String url) async {
    _socket = await WebSocket.connect(url);
    _connected = true;
    print('✅ Conectado a $url');

    _socket.listen((data) {
      final msg = jsonDecode(data);
      if (msg is Map<String, dynamic>) {
        final type = msg['type'];
        onServerEvent?.call(type, msg); // uso seguro con null check
      }
    }, onDone: () {
      print('🔌 Desconectado del servidor');
      _connected = false;
    });
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
    } else {
      print('⚠️ No conectado. Mensaje no enviado: $msg');
    }
  }

  void close() {
    _socket.close();
  }
}