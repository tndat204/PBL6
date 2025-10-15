// lib/features/admin/admin_shell.dart
import 'package:flutter/material.dart';

import '../../features/shared/widgets/app_layout.dart';
import '../../features/user/jobs/domain/entities/user.dart';

class AdminShell extends StatelessWidget {
  final User user;
  final Widget child;
  const AdminShell({super.key, required this.user, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      user: user,
      child: child,
      routes: ['/admin/home', '/admin/manage', '/admin/notification', '/admin/profile'],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: ''),
      ],
    );
  }
}
