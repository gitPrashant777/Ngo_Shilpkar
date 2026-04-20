import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/utils/storage_service.dart';

class SocketService {
  bool _isInitialized = false;
  late IO.Socket _socket;
  final StorageService _storage = StorageService();

  // Initialize Socket
  Future<void> initSocket(String baseUrl) async {
    if (_isInitialized) return;

    final token = await _storage.getToken();

    final uri = Uri.parse(baseUrl);
    // Socket server is typically at the root of the domain, not /api
    final socketUrl = "${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}";

    _socket = IO.io(
      socketUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'}) // Standard header auth
        .disableAutoConnect()
        .build()
    );

    _socket.connect();
    
    _socket.onConnect((_) {
      print('🔌 Socket Connected to $socketUrl');
      _isInitialized = true;
    });

    _socket.onDisconnect((_) {
      print('🔌 Socket Disconnected');
      _isInitialized = false;
    });
    
    _socket.on('error', (data) => print('❌ Socket Error: $data'));
  }

  // Join Chat Room
  void joinSession(String sessionId) {
    if (!_isInitialized) {
      print('⚠️ Socket not initialized. Cannot join session: $sessionId');
      return;
    }
    _socket.emit('join-session', sessionId);
  }

  // Send Message
  void sendMessage(String sessionId, String text, {String? fileUrl, String? fileType}) {
    if (!_isInitialized) {
       print('⚠️ Socket not initialized. Cannot send message via socket.');
       return;
    }
    _socket.emit('send-message', {
      'chatSessionId': sessionId,
      'text': text,
      'fileUrl': fileUrl,
      'fileType': fileType,
    });
  }

  // Listen for New Messages
  void onNewMessage(Function(dynamic) callback) {
    if (!_isInitialized) return;
    _socket.on('new-message', (data) {
      callback(data);
    });
  }

  // Listen for Broadcasts
  void onBroadcast(Function(dynamic) callback) {
    if (!_isInitialized) return;
    _socket.on('broadcast-message', (data) {
      callback(data);
    });
  }

  // Dispose
  void disconnect() {
    if (_isInitialized) {
      _socket.disconnect();
      _isInitialized = false;
    }
  }
}
