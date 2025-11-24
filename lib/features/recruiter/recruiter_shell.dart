import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/core/theme/app_pallete.dart'; // THÊM IMPORT
import 'package:pbl6/features/shared/widgets/custom_bottom_nav.dart';

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
    // SỬA: Dựa trên router của bạn, route này nên là /projects
    '/recruiter/reviews',
    '/recruiter/profile',
  ];

  // SỬA: Cập nhật hàm build dựa trên UserShell
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
                // SỬA: Thêm label cho các item
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded), label: 'Tổng quan'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.work_outline_rounded),
                      label: 'Quản lý Job'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.assessment_outlined),
                      label: 'Đánh giá'), // Dựa trên route '/projects'
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      label: 'Công ty'), // Hoặc 'Hồ sơ'
                ],
              ),
            ),
          ),
        ],
      ),
      extendBody: true, // ✅ Giúp nội dung phía dưới hiển thị mượt khi bar nổi
      // SỬA: Đổi màu nền để khớp với UserShell
      backgroundColor: AppPallete.backgroundColor,
    );
  }
}