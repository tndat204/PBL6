// lib/features/jobs/presentation/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

import '../../user/jobs/domain/entities/user.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User user;

  const CustomAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      title: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: const AssetImage('assets/images/avatar.png'),
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.name,
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
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700, size: 30),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
