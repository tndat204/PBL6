import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<Notification>> getNotifications() async {
    return await remoteDatasource.getNotifications();
  }

  @override
  Future<void> markAllRead() async {
    return await remoteDatasource.markAllRead();
  }

  @override
  Future<void> markRead(String id) async {
    return await remoteDatasource.markRead(id);
  }

}