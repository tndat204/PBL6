import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/notification/presentation/manager/notification_provider.dart';
import 'package:pbl6/features/shared/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart'; 

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
    '/user/applications',
    '/user/profile',
  ];

  @override
  void initState() {
    super.initState();
    
    // 3. Kích hoạt logic kết nối Socket & lấy thông báo ngay khi vào Shell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Dùng context.read để gọi hàm mà không lắng nghe thay đổi UI ở đây
        context.read<NotificationProvider>().init();
      }
    });
  }

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
            bottom: 12, 
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
                      icon: Icon(Icons.home_rounded), label: 'Tổng quan'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.work_outline_rounded), label: 'Việc làm'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Ứng tuyển'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded), label: 'Hồ sơ'),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true, 
      backgroundColor: AppPallete.backgroundColor,
    );
  }
}