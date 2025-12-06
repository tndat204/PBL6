import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../domain/entities/notification.dart';

class WebSocketService {
  StompClient? _stompClient;

  // Stream controller để đẩy thông báo mới ra cho Provider
  final _notiStreamController = StreamController<Notification>.broadcast();
  Stream<Notification> get notificationStream => _notiStreamController.stream;

  // --- Thay đổi: Nhận token trực tiếp từ tham số, không tự mò Local Storage ---
  void connect(String userId, String token) {
    // URL: Thay IP phù hợp
    const socketUrl = 'ws://10.0.2.2:8080/ws/websocket';

    _stompClient = StompClient(
      config: StompConfig(
        url: socketUrl,
        onConnect: (frame) {
          print("✅ Socket: Kết nối thành công!");
          _subscribe(userId);
        },
        onWebSocketError: (err) => print("❌ Socket Lỗi: $err"),
        onStompError: (frame) => print("❌ Stomp Lỗi: ${frame.body}"),
        onDisconnect: (_) => print("⚠️ Socket: Đã ngắt kết nối"),

        // Gửi token nhận được vào Header
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient?.activate();
  }

  void _subscribe(String userId) {
    // Topic: /topic/user/{userId}/notify
    final topic = '/topic/user/$userId/notify';

    _stompClient?.subscribe(
      destination: topic,
      callback: (frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            final notification = Notification.fromJson(data);

            _notiStreamController.add(notification);
            print("📩 Socket nhận tin: ${notification.title}");
          } catch (e) {
            print("⚠️ Lỗi parse socket: $e");
          }
        }
      },
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
  }
}
