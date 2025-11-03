import 'package:flutter/material.dart';

class RecruiterDashboard extends StatelessWidget {
  const RecruiterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'dashboardTitle',
        child: const Text(
          'Chào mừng bạn đến trang tổng quan nhà tuyển dụng!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center, 
        ),
      ),
    );
  }
}
