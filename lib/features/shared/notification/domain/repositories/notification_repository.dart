import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}