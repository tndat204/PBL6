import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_constants.dart';
import '../../user/jobs/domain/entities/user.dart';
import '../user/presentation/providers/user_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user; // ✅ nhận user từ bên ngoài (có thể null)

  const CustomAppBar({super.key, this.user});

  @override
  Widget build(BuildContext context) {

   
    final effectiveUser = context.watch<UserProvider>().user ?? user;

    if (effectiveUser == null) {
      return AppBar(title: const Text('Đang tải...'));
    }

    final avatarUrl = effectiveUser.avatarUrl.isNotEmpty
        ? (effectiveUser.avatarUrl.startsWith('http')
            ? effectiveUser.avatarUrl
            : '${ApiConstants.baseUrl}${effectiveUser.avatarUrl}')
        : null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      title: GestureDetector(
        onTap: () => context.push('/user/my-info'),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : const AssetImage('assets/images/avatar.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 12),
            Column(
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
                Text(
                  effectiveUser.fullName.isNotEmpty
                      ? effectiveUser.fullName
                      : 'Người dùng',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 30),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
