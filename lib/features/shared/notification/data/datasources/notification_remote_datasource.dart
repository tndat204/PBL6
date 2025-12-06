import 'package:dio/dio.dart';
import 'package:pbl6/core/constants/api_constants.dart';

import '../../domain/entities/notification.dart';

abstract class NotificationRemoteDatasource {
  Future<List<Notification>> getNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final Dio _dio;

  NotificationRemoteDatasourceImpl(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
  }

  @override
  Future<List<Notification>> getNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notifications);
      if (response.statusCode == 200 && response.data['result'] != null) {
        final List<dynamic> data = response.data['result'];
        return data.map((e) => Notification.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Lỗi lấy thông báo: $e");
    }
  }

  @override
  Future<void> markAllRead() async {
   try{
     await _dio.put('${ApiConstants.notifications}/read-all');
   }
   catch(e){
     throw Exception("Lỗi đánh dấu tất cả đã đọc: $e");
   }
  }

  @override
  Future<void> markRead(String id) async {
    try{
      await _dio.put('${ApiConstants.notifications}/$id/read');
    }
    catch(e){
      throw Exception("Lỗi đánh dấu đã đọc: $e");
    }
  }
}
