import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecruiterDashboard extends StatefulWidget {
  final Widget child;
  const RecruiterDashboard({super.key, required this.child});

  @override
  State<RecruiterDashboard> createState() => _RecruiterDashboardState();
}

class _RecruiterDashboardState extends State<RecruiterDashboard> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/recruiter/home',
    '/recruiter/projects',
    '/recruiter/messages',
    '/recruiter/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhà tuyển dụng'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
            context.go(_routes[index]);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Dự án'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
