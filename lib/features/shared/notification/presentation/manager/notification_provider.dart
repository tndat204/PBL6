import 'package:flutter/material.dart' hide Notification;
import 'package:get_it/get_it.dart';

import '../../../auth/domain/usecases/get_auth_token_usecase.dart';
import '../../../auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../data/datasources/websocket_service.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

class NotificationProvider extends ChangeNotifier {
  // 1. Inject Notification UseCases
  final GetNotificationsUseCase _getNotificationsUC =
      GetIt.I<GetNotificationsUseCase>();
  final MarkNotificationReadUseCase _markReadUC =
      GetIt.I<MarkNotificationReadUseCase>();
  final MarkAllNotificationsReadUseCase _markAllReadUC =
      GetIt.I<MarkAllNotificationsReadUseCase>();

  // 2. Inject Auth UseCases (Để lấy ID và Token)
  final GetCurrentUserIdUseCase _getUserIdUC =
      GetIt.I<GetCurrentUserIdUseCase>();
  final GetAuthTokenUseCase _getTokenUC = GetIt.I<GetAuthTokenUseCase>();

  // Service Socket (Giữ instance để duy trì kết nối)
  final WebSocketService _socketService = WebSocketService();

  List<Notification> _notifications = [];
  List<Notification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // --- INIT: Gọi khi Login xong hoặc mở App ---
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // BƯỚC 1: Lấy UserId và Token từ Auth Repository (qua UseCase)
      final userId = await _getUserIdUC();
      final token = await _getTokenUC();

      if (userId == null || token == null) {
        print("⚠️ Chưa đăng nhập hoặc thiếu token -> Không load thông báo");
        _isLoading = false;
        notifyListeners();
        return;
      }

      // BƯỚC 2: Gọi API lấy lịch sử thông báo
      final history = await _getNotificationsUC.call();
      _notifications = history;
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // BƯỚC 3: Kết nối Socket (Truyền ID và Token vào)
      _socketService.connect(userId, token);

      // BƯỚC 4: Lắng nghe Socket
      _socketService.notificationStream.listen((newNoti) {
        // Có tin mới -> Thêm vào đầu list
        _notifications.insert(0, newNoti);
        notifyListeners();
      });
    } catch (e) {
      print("❌ Lỗi khởi tạo Notification: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CÁC HÀM XỬ LÝ KHÁC (Giữ nguyên) ---
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      try {
        await _markReadUC.call(id);
      } catch (e) {
        print("Lỗi mark read: $e");
      }
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
    try {
      await _markAllReadUC.call();
    } catch (e) {
      print("Lỗi mark all read: $e");
    }
  }

  void clearAndDisconnect() {
    _socketService.disconnect();
    _notifications = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
