import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/features/shared/widgets/custom_bottom_nav.dart';



class UserShell extends StatefulWidget {
  final Widget child;
  const UserShell({super.key, required this.child});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/user/dashboard',
    '/user/jobs',
    '/user/messages',
    '/user/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// --- Nội dung chính ---
          Positioned.fill(
            child: widget.child,
          ),

          /// --- Bottom nav nổi ---
          Positioned(
            left: 0,
            right: 0,
            bottom: 12, // Cách mép dưới một chút để nhìn nổi lên
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNav(
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (_currentIndex != index) {
                    setState(() => _currentIndex = index);
                    context.go(_routes[index]);
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded), label: ''),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.work_outline_rounded), label: ''),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.chat_bubble_outline_rounded), label: ''),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded), label: ''),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true, // ✅ Giúp nội dung phía dưới hiển thị mượt khi bar nổi
      backgroundColor: Colors.transparent,
    );
  }
}

