import 'package:flutter/material.dart';

class RecruiterDashboard extends StatelessWidget {


  const RecruiterDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recruiter Dashboard'),
        backgroundColor: Colors.green, // Mock color for recruiter
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Welcome to Recruiter Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Manage jobs, profiles, reports, companies'),
          ],
        ),
      ),
    );
  }
}