import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl6/core/theme/app_pallete.dart'; // Import bảng màu của bạn
import 'package:provider/provider.dart';

import '../../domain/entities/notification.dart' as entity;
import '../manager/notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng giống JobDetail
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER CUSTOM (Giống JobDetail) ---
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Thông báo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  // Nút đánh dấu đã đọc bên phải
                  IconButton(
                    icon: const Icon(Icons.done_all_rounded, color: AppPallete.primaryColor),
                    tooltip: "Đánh dấu tất cả đã đọc",
                    onPressed: () {
                      context.read<NotificationProvider>().markAllAsRead();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)), // Line ngăn cách nhẹ

            // --- BODY ---
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.notifications.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    color: AppPallete.primaryColor,
                    onRefresh: () async => await provider.init(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: provider.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12), // Khoảng cách giữa các item
                      itemBuilder: (context, index) {
                        final noti = provider.notifications[index];
                        return _buildNotificationItem(context, noti);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            "Bạn chưa có thông báo nào",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, entity.Notification noti) {
    // Style: Chưa đọc thì nền hơi xanh/đậm hơn, Đã đọc thì nền trắng/xám nhạt
    final isUnread = !noti.isRead;
    
    return InkWell(
      onTap: () {
        context.read<NotificationProvider>().markAsRead(noti.id);
        if (noti.targetUrl.isNotEmpty) {
          // Xử lý navigate
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F7FF) : Colors.white, // Xanh nhạt vs Trắng
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? AppPallete.primaryColor.withOpacity(0.3) : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isUnread 
              ? [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon bên trái
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnread ? AppPallete.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconByType(noti.type),
                color: isUnread ? AppPallete.primaryColor : Colors.grey.shade500,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Nội dung text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          noti.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Chấm đỏ nếu chưa đọc
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    noti.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnread ? Colors.black87 : Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(noti.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    // Nếu trong ngày thì hiện giờ, khác ngày hiện ngày tháng
    final now = DateTime.now();
    if (time.year == now.year && time.month == now.month && time.day == now.day) {
      return DateFormat('HH:mm').format(time); // VD: 14:30
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(time); // VD: 12/05/2024 14:30
  }

  IconData _getIconByType(String type) {
    switch (type) {
      case 'JOB_APPLICATION':
        return Icons.work_outline_rounded;
      case 'INTERVIEW':
        return Icons.video_camera_front_outlined;
      case 'HIRED':
        return Icons.celebration_rounded;
      case 'REJECTED':
        return Icons.cancel_outlined;
      case 'SYSTEM':
      default:
        return Icons.notifications_none_rounded;
    }
  }
}