import 'package:flutter/material.dart';

class RecruiterDashboard extends StatelessWidget {
  const RecruiterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Chào mừng bạn đến trang tổng quan nhà tuyển dụng!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
