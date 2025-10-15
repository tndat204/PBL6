
import 'package:flutter/material.dart';

import '../../features/shared/widgets/app_layout.dart';
import '../../features/user/jobs/domain/entities/user.dart';

class RecruiterShell extends StatelessWidget {
  final User user;
  final Widget child;
  const RecruiterShell({super.key, required this.user, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      user: user,
      child: child,
      routes: ['/recruiter/home', '/recruiter/project', '/recruiter/chat', '/recruiter/profile'],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.work_outline_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: ''),
      ],
    );
  }
}
