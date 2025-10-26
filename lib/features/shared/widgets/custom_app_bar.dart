// file: features/shared/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../user/presentation/providers/user_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Remove the user parameter
  // final User? user;
  const CustomAppBar({super.key}); // Update constructor

  @override
  Widget build(BuildContext context) {
    // Directly watch the provider
    final effectiveUser = context.watch<UserProvider>().user;

    // Show a basic AppBar while user is loading (or handle null differently)
    if (effectiveUser == null) {
      // You could return an empty AppBar or a placeholder
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: const Text('Đang tải...'), // Or keep it blank
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 30),
            onPressed: () {},
          ),
        ],
      );
    }

    // ✅ SIMPLIFIED URL LOGIC (as done previously)
    final avatarUrl = effectiveUser.avatarUrl.isNotEmpty ? effectiveUser.avatarUrl : null;

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
                      : 'Người dùng', // Fallback name
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