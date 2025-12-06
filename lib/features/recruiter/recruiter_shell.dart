import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
// 2. Import NotificationProvider
import 'package:pbl6/features/shared/notification/presentation/manager/notification_provider.dart';
import 'package:pbl6/features/shared/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart'; // 1. Import Provider

class RecruiterShell extends StatefulWidget {
  final Widget child;
  const RecruiterShell({super.key, required this.child});

  @override
  State<RecruiterShell> createState() => _RecruiterShellState();
}

class _RecruiterShellState extends State<RecruiterShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/recruiter/dashboard',
    '/recruiter/jobs',
    '/recruiter/reviews',
    '/recruiter/profile',
  ];

  @override
  void initState() {
    super.initState();
    
    // 3. Kích hoạt kết nối Socket & lấy thông báo cho Recruiter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
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
                      icon: Icon(Icons.home_rounded), label: 'Tổng quan'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.work_outline_rounded),
                      label: 'Quản lý Job'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.assessment_outlined),
                      label: 'Đánh giá'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      label: 'Công ty'),
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true, // ✅ Giúp nội dung phía dưới hiển thị mượt khi bar nổi
      backgroundColor: AppPallete.backgroundColor,
    );
  }
}