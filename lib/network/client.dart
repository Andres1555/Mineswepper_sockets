import 'dart:convert';
import 'dart:io';


typedef OnServerEvent = void Function(String type, Map<String, dynamic> msg);

class WebSocketClient {
  late WebSocket _socket;
  bool _connected = false;
  OnServerEvent? onServerEvent; 

  WebSocketClient();

  Future<void> connect(String url) async {
    try {
      _socket = await WebSocket.connect(url);
      _connected = true;
      print('✅ Conectado a $url');

      _socket.listen((data) {
        final msg = jsonDecode(data);
        if (msg is Map<String, dynamic>) {
          final type = msg['type'];
          if (type == 'turn') {
            final currentPlayer = msg['currentPlayer'];
            print('🔄 Turno del jugador $currentPlayer');
          }
          onServerEvent?.call(type, msg);
        }
      }, onDone: () {
        print('🔌 Desconectado del servidor');
        _connected = false;
      });
    } catch (e) {
      print('❌ Error al conectar a $url: $e');
      rethrow; // Lanzar la excepción para que la UI la maneje
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
    } else {
      print('⚠️ No conectado. Mensaje no enviado: $msg');
    }
  }

  void close() {
    _socket.close();
  }
}