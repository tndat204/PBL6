import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../user/jobs/domain/entities/user.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User user;

  const CustomAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Base URL của server (có thể chỉnh theo Dũng dùng)
    const String baseUrl = ApiConstants.baseUrl; // Hoặc domain thật

    // Tạo đường dẫn đầy đủ cho avatar (nếu có)
    final String? avatarUrl = (user.avatarUrl.isNotEmpty)
        ? (user.avatarUrl.startsWith('http')
            ? user.avatarUrl
            : '$baseUrl${user.avatarUrl}')
        : null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl)
                : const AssetImage('assets/images/avatar.png') as ImageProvider,
            onBackgroundImageError: (_, __) {
              // Nếu load lỗi thì fallback về ảnh mặc định
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.fullName.isNotEmpty ? user.fullName : 'Người dùng',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.grey.shade700,
              size: 30,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
